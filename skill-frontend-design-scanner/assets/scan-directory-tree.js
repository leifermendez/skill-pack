#!/usr/bin/env node
/**
 * Directory Tree Scanner (Async, v2)
 * Escanea recursivamente directorios y archivos, retornando sus paths estructurados.
 * Respeta .gitignore (con negaciones, globs, patterns anclados), ignora node_modules, .next, dist, build, coverage, .git.
 * Protegido contra symlinks circulares.
 * I/O 100% async (non-blocking).
 *
 * Uso CLI:
 *   node scan-directory-tree.js <project-path> [--json] [--flat] [--include=ext1,ext2]
 *   node scan-directory-tree.js ./my-project --json --include=js,jsx,ts,tsx
 *
 * Uso Programático (async):
 *   const { scanDirectoryTree } = require('./scan-directory-tree');
 *   const tree = await scanDirectoryTree('/path/to/project');
 */

const fs = require('fs').promises;
const path = require('path');

// Carpetas y patrones ignorados por defecto
const DEFAULT_IGNORED = [
  'node_modules',
  '.git',
  '.next',
  'dist',
  'build',
  'coverage',
  '.turbo',
  '.vercel',
  '.cache',
  'out',
  '.storybook',
  'playwright-report',
  'test-results',
  '__snapshots__',
];

/**
 * Lee y parsea un archivo .gitignore retornando patrones relevantes
 * Soporta negaciones (!pattern), comodines (*, **), patterns anclados (/pattern)
 * @param {string} gitignorePath
 * @returns {Promise<{positive: string[], negative: string[]}>}
 */
async function readGitignore(gitignorePath) {
  try {
    const content = await fs.readFile(gitignorePath, 'utf-8');
    const lines = content
      .split('\n')
      .map((line) => line.trim())
      .filter((line) => line && !line.startsWith('#'));

    const positive = [];
    const negative = [];

    for (const line of lines) {
      if (line.startsWith('!')) {
        negative.push(line.slice(1));
      } else {
        positive.push(line);
      }
    }

    return { positive, negative };
  } catch {
    return { positive: [], negative: [] };
  }
}

/**
 * Escapa caracteres especiales de regex excepto * que se convierte en .*
 * @param {string} str
 * @returns {string}
 */
function escapeRegex(str) {
  return str.replace(/[.+^${}()|[\]\\]/g, '\\$&').replace(/\*/g, '.*');
}

/**
 * Convierte un pattern de gitignore a regex
 * @param {string} pattern
 * @returns {RegExp|null}
 */
function gitignoreToRegex(pattern) {
  if (!pattern) return null;

  let anchored = false;
  let isDir = false;
  let pat = pattern;

  if (pat.startsWith('/')) {
    anchored = true;
    pat = pat.slice(1);
  }

  if (pat.endsWith('/')) {
    isDir = true;
    pat = pat.slice(0, -1);
  }

  // Reemplazar **/ por (?:.*/)?
  pat = pat.replace(/\*\*\//g, '(?:.*/)?');
  // Reemplazar /** por (/.*)?
  pat = pat.replace(/\/\*\*$/, '(/.*)?');
  // Reemplazar ** por .*
  pat = pat.replace(/\*\*/g, '.*');

  const regexStr = anchored
    ? '^' + escapeRegex(pat) + (isDir ? '(/.*)?$' : '$')
    : '(^|/)' + escapeRegex(pat) + (isDir ? '(/.*)?$' : '$');

  try {
    return new RegExp(regexStr);
  } catch {
    return null;
  }
}

/**
 * Verifica si un path debe ser ignorado según patterns de gitignore
 * @param {string} relPath — path relativo al root
 * @param {string} name — nombre del archivo/directorio
 * @param {boolean} isDirectory
 * @param {{positive: string[], negative: string[]}} patterns
 * @param {string[]} extraIgnored
 * @returns {boolean}
 */
function shouldIgnore(relPath, name, isDirectory, patterns, extraIgnored) {
  // Ignorados por defecto
  if (DEFAULT_IGNORED.includes(name)) return true;
  if (extraIgnored.includes(name)) return true;

  const testPath = relPath.replace(/\\/g, '/');

  // Verificar negaciones primero
  for (const neg of patterns.negative) {
    const regex = gitignoreToRegex(neg);
    if (regex && regex.test(testPath)) {
      return false; // No ignorar (excepción)
    }
  }

  // Verificar patterns positivos
  for (const pat of patterns.positive) {
    const regex = gitignoreToRegex(pat);
    if (regex && regex.test(testPath)) {
      return true;
    }
    // Match exacto simple para compatibilidad
    if (pat === name || pat === testPath || testPath.endsWith('/' + pat)) {
      return true;
    }
  }

  return false;
}

/**
 * Opciones de escaneo
 * @typedef {Object} ScanOptions
 * @property {boolean} [includeFiles=true]
 * @property {boolean} [includeDirs=true]
 * @property {boolean} [flat=false] — si true, retorna array plano de paths
 * @property {string[]} [extensions=null] — filtrar por extensiones, ej: ['js','jsx']
 * @property {string[]} [extraIgnored=[]] — nombres adicionales a ignorar
 * @property {boolean} [respectGitignore=true]
 * @property {number} [maxDepth=Infinity]
 * @property {boolean} [includeSize=false] — incluir tamaño de archivos (requiere stat adicional)
 * @property {number} [maxFiles=50000] — límite de archivos para evitar OOM
 */

/**
 * Escanea un directorio recursivamente (implementación interna)
 * @param {string} dirPath — path absoluto a escanear
 * @param {ScanOptions} options
 * @param {string} relativePath — path relativo al root
 * @param {number} currentDepth — profundidad actual
 * @param {Set<string>} visitedInodes — inodes visitados (protección symlinks)
 * @param {{count: number}} fileCounter — contador de archivos procesados
 * @returns {Promise<Object|Array|null>} árbol de directorios o array plano si flat=true
 */
async function scanDirectoryTreeInternal(
  dirPath,
  options,
  relativePath,
  currentDepth,
  visitedInodes,
  fileCounter
) {
  const {
    includeFiles = true,
    includeDirs = true,
    flat = false,
    extensions = null,
    extraIgnored = [],
    respectGitignore = true,
    maxDepth = Infinity,
    includeSize = false,
    maxFiles = 50000,
  } = options;

  if (currentDepth > maxDepth) {
    return flat ? [] : null;
  }

  if (fileCounter.count >= maxFiles) {
    return flat ? [] : null;
  }

  // Protección contra symlinks circulares
  try {
    const stat = await fs.lstat(dirPath);
    if (stat.isSymbolicLink()) {
      return flat ? [] : null;
    }
    const inodeKey = `${stat.dev}:${stat.ino}`;
    if (visitedInodes.has(inodeKey)) {
      return flat ? [] : null; // Evitar loop
    }
    visitedInodes.add(inodeKey);
  } catch {
    return flat ? [] : null;
  }

  const gitignorePath = path.join(dirPath, '.gitignore');
  const gitignorePatterns = respectGitignore
    ? await readGitignore(gitignorePath)
    : { positive: [], negative: [] };

  let entries;
  try {
    entries = await fs.readdir(dirPath, { withFileTypes: true });
  } catch {
    return flat ? [] : null;
  }

  const flatResults = [];
  const treeResult = {
    path: relativePath || '.',
    absolutePath: dirPath,
    type: 'directory',
    children: [],
  };

  for (const entry of entries) {
    const entryRelPath = relativePath
      ? `${relativePath}/${entry.name}`
      : entry.name;

    if (
      shouldIgnore(
        entryRelPath,
        entry.name,
        entry.isDirectory(),
        gitignorePatterns,
        extraIgnored
      )
    ) {
      continue;
    }

    const entryAbsPath = path.join(dirPath, entry.name);

    if (entry.isDirectory()) {
      const childTree = await scanDirectoryTreeInternal(
        entryAbsPath,
        options,
        entryRelPath,
        currentDepth + 1,
        visitedInodes,
        fileCounter
      );

      if (childTree) {
        if (flat) {
          flatResults.push(...childTree);
          if (includeDirs) {
            flatResults.push({
              path: entryRelPath,
              absolutePath: entryAbsPath,
              type: 'directory',
            });
          }
        } else {
          if (includeDirs) {
            treeResult.children.push(childTree);
          } else {
            treeResult.children.push(...childTree.children);
          }
        }
      }
    } else if (entry.isFile() && includeFiles) {
      const ext = path.extname(entry.name).replace(/^\./, '').toLowerCase();

      if (extensions && !extensions.includes(ext)) {
        continue;
      }

      fileCounter.count++;

      const fileNode = {
        path: entryRelPath,
        absolutePath: entryAbsPath,
        type: 'file',
        name: entry.name,
        extension: ext,
      };

      if (includeSize) {
        try {
          const fstat = await fs.stat(entryAbsPath);
          fileNode.size = fstat.size;
        } catch {
          fileNode.size = -1;
        }
      }

      if (flat) {
        flatResults.push(fileNode);
      } else {
        treeResult.children.push(fileNode);
      }
    }
  }

  return flat ? flatResults : treeResult;
}

/**
 * Escanea un directorio recursivamente (API pública)
 * @param {string} dirPath — path absoluto a escanear
 * @param {ScanOptions} [options={}]
 * @returns {Promise<Object|Array>} árbol de directorios o array plano si flat=true
 */
async function scanDirectoryTree(dirPath, options = {}) {
  const visitedInodes = new Set();
  const fileCounter = { count: 0 };
  return scanDirectoryTreeInternal(
    path.resolve(dirPath),
    options,
    '',
    0,
    visitedInodes,
    fileCounter
  );
}

/**
 * Versión simplificada: retorna solo un array de paths absolutos
 * @param {string} dirPath
 * @param {ScanOptions} [options={}]
 * @returns {Promise<string[]>}
 */
async function scanPaths(dirPath, options = {}) {
  const flatOpts = { ...options, flat: true, includeDirs: false };
  const results = await scanDirectoryTree(dirPath, flatOpts);
  return results.map((r) => r.absolutePath);
}

/**
 * Versión simplificada: retorna solo un array de paths relativos
 * @param {string} dirPath
 * @param {ScanOptions} [options={}]
 * @returns {Promise<string[]>}
 */
async function scanRelativePaths(dirPath, options = {}) {
  const flatOpts = { ...options, flat: true, includeDirs: false };
  const results = await scanDirectoryTree(dirPath, flatOpts);
  return results.map((r) => r.path);
}

// ============ CLI ============

function parseArgs(argv) {
  const args = argv.slice(2);

  if (args.includes('--help') || args.includes('-h')) {
    console.log(`
Directory Tree Scanner

Uso: node scan-directory-tree.js <project-path> [opciones]

Opciones:
  --json              Output en formato JSON
  --flat              Output plano (array de entradas)
  --include=ext1,ext2 Filtrar por extensiones
  --max-depth=N       Limitar profundidad de escaneo
  --include-size      Incluir tamaño de archivos
  --no-gitignore      Ignorar .gitignore
  --help, -h          Mostrar esta ayuda

Ejemplos:
  node scan-directory-tree.js ./mi-proyecto
  node scan-directory-tree.js ./mi-proyecto --json --include=js,jsx,ts,tsx
  node scan-directory-tree.js ./mi-proyecto --flat --max-depth=3
`);
    process.exit(0);
  }

  const projectPath = args.find((a) => !a.startsWith('--')) || process.cwd();
  const useJson = args.includes('--json');
  const flatMode = args.includes('--flat');
  const includeSize = args.includes('--include-size');
  const noGitignore = args.includes('--no-gitignore');

  const includeArg = args.find((a) => a.startsWith('--include='));
  const extensions = includeArg
    ? includeArg.split('=')[1].split(',').map((s) => s.trim().toLowerCase())
    : null;

  const maxDepthArg = args.find((a) => a.startsWith('--max-depth='));
  const maxDepth = maxDepthArg
    ? parseInt(maxDepthArg.split('=')[1], 10)
    : Infinity;

  return {
    projectPath,
    useJson,
    flatMode,
    includeSize,
    noGitignore,
    extensions,
    maxDepth,
  };
}

function printTree(node, prefix = '', isLast = true) {
  if (node.type === 'file') {
    const sizeStr = node.size !== undefined ? ` (${node.size} bytes)` : '';
    console.log(`${prefix}${isLast ? '└── ' : '├── '}${node.name}${sizeStr}`);
    return;
  }

  const dirName =
    node.path === '.'
      ? path.basename(node.absolutePath)
      : path.basename(node.path);
  console.log(
    `${prefix}${isLast ? '└── ' : '├── '}${dirName}/`
  );

  if (node.children && node.children.length > 0) {
    const lastIndex = node.children.length - 1;
    node.children.forEach((child, index) => {
      const childIsLast = index === lastIndex;
      const newPrefix = prefix + (isLast ? '    ' : '│   ');
      printTree(child, newPrefix, childIsLast);
    });
  }
}

async function main() {
  const {
    projectPath,
    useJson,
    flatMode,
    includeSize,
    noGitignore,
    extensions,
    maxDepth,
  } = parseArgs(process.argv);

  const absPath = path.resolve(projectPath);

  try {
    const stat = await fs.stat(absPath);
    if (!stat.isDirectory()) {
      console.error(`Error: El path no es un directorio: ${absPath}`);
      process.exit(1);
    }
  } catch {
    console.error(`Error: El path no existe: ${absPath}`);
    process.exit(1);
  }

  const options = {
    flat: flatMode,
    extensions,
    maxDepth: isFinite(maxDepth) ? maxDepth : Infinity,
    includeSize,
    respectGitignore: !noGitignore,
  };

  const result = await scanDirectoryTree(absPath, options);

  if (useJson) {
    console.log(JSON.stringify(result, null, 2));
  } else if (flatMode) {
    result.forEach((item) => {
      console.log(`${item.path}`);
    });
  } else {
    printTree(result);
  }
}

if (require.main === module) {
  main().catch((err) => {
    console.error('Error inesperado:', err.message);
    process.exit(1);
  });
}

module.exports = {
  scanDirectoryTree,
  scanPaths,
  scanRelativePaths,
  readGitignore,
  shouldIgnore,
  DEFAULT_IGNORED,
};
