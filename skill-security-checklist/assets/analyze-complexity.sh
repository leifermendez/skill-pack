#!/bin/bash
# Analyze code complexity and detect code smells
# Output: YAML to stdout

PROJECT_PATH="${1:-.}"
cd "$PROJECT_PATH" || exit 1

echo "project_path: $(pwd)"
echo "audit_timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Find source files
SOURCE_FILES=$(find . -type f \( -name '*.js' -o -name '*.ts' -o -name '*.jsx' -o -name '*.tsx' -o -name '*.py' -o -name '*.java' -o -name '*.go' -o -name '*.rs' -o -name '*.php' -o -name '*.rb' -o -name '*.cs' -o -name '*.swift' -o -name '*.kt' -o -name '*.c' -o -name '*.cpp' -o -name '*.h' -o -name '*.hpp' \) -not -path './node_modules/*' -not -path './vendor/*' -not -path './.git/*' -not -path './dist/*' -not -path './build/*' -not -path './target/*' -not -path './.next/*')

TOTAL_FILES=$(echo "$SOURCE_FILES" | wc -l)
echo "total_source_files: $TOTAL_FILES"

# Calculate file sizes
echo "file_size_analysis:"
LARGE_FILES=0
VERY_LARGE_FILES=0
MEDIUM_FILES=0
SMALL_FILES=0

while IFS= read -r file; do
    if [ -f "$file" ]; then
        lines=$(wc -l < "$file")
        if [ "$lines" -gt 500 ]; then
            VERY_LARGE_FILES=$((VERY_LARGE_FILES + 1))
            echo "  - file: $file"
            echo "    lines: $lines"
            echo "    category: very_large"
        elif [ "$lines" -gt 300 ]; then
            LARGE_FILES=$((LARGE_FILES + 1))
            echo "  - file: $file"
            echo "    lines: $lines"
            echo "    category: large"
        elif [ "$lines" -gt 100 ]; then
            MEDIUM_FILES=$((MEDIUM_FILES + 1))
        else
            SMALL_FILES=$((SMALL_FILES + 1))
        fi
    fi
done <<< "$SOURCE_FILES"

echo "file_size_summary:"
echo "  very_large: $VERY_LARGE_FILES"
echo "  large: $LARGE_FILES"
echo "  medium: $MEDIUM_FILES"
echo "  small: $SMALL_FILES"

# Calculate average file size
if [ "$TOTAL_FILES" -gt 0 ]; then
    TOTAL_LINES=$(echo "$SOURCE_FILES" | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}')
    if [ -n "$TOTAL_LINES" ] && [ "$TOTAL_LINES" -gt 0 ]; then
        AVG_LINES=$((TOTAL_LINES / TOTAL_FILES))
        echo "average_file_size: $AVG_LINES"
    fi
fi

# Detect code smells
echo "code_smells:"

# God classes / large files
if [ "$VERY_LARGE_FILES" -gt 0 ] || [ "$LARGE_FILES" -gt 0 ]; then
    echo "  - smell: god_class"
    echo "    severity: high"
    echo "    count: $((VERY_LARGE_FILES + LARGE_FILES))"
    echo "    description: Files with >300 lines indicate possible god classes"
    echo "    recommendation: Split into smaller, single-responsibility files"
fi

# Deep nesting detection (simple heuristic)
NESTED_FILES=$(echo "$SOURCE_FILES" | while read -r file; do
    if [ -f "$file" ]; then
        max_indent=0
        while IFS= read -r line; do
            # Count leading spaces or tabs
            indent=$(echo "$line" | sed 's/[^\t].*//' | wc -c)
            if [ "$indent" -gt "$max_indent" ]; then
                max_indent=$indent
            fi
        done < "$file"
        if [ "$max_indent" -gt 8 ]; then
            echo "$file"
        fi
    fi
done | wc -l)

if [ "$NESTED_FILES" -gt 0 ]; then
    echo "  - smell: deep_nesting"
    echo "    severity: medium"
    echo "    count: $NESTED_FILES"
    echo "    description: Files with excessive indentation (>8 levels)"
    echo "    recommendation: Refactor nested logic into functions or early returns"
fi

# Long function detection (simple heuristic for JS/TS/Python)
LONG_FUNCTIONS=0
JS_TS_FILES=$(echo "$SOURCE_FILES" | grep -E '\.(js|ts|jsx|tsx)$')
if [ -n "$JS_TS_FILES" ]; then
    LONG_FUNCTIONS=$(echo "$JS_TS_FILES" | while read -r file; do
        if [ -f "$file" ]; then
            awk '
                /^function / || /^const .* = / || /^async function / || /^.*\(.*\).*{/ {
                    if (start > 0 && count > 50) {
                        print FILENAME ":" count
                    }
                    start = NR
                    count = 0
                    brace = 0
                }
                start > 0 {
                    count++
                    brace += gsub(/{/, "")
                    brace -= gsub(/}/, "")
                    if (brace == 0 && count > 1) {
                        if (count > 50) {
                            print FILENAME ":" count
                        }
                        start = 0
                    }
                }
            ' "$file"
        fi
    done | wc -l)
fi

if [ "$LONG_FUNCTIONS" -gt 0 ]; then
    echo "  - smell: long_function"
    echo "    severity: medium"
    echo "    count: $LONG_FUNCTIONS"
    echo "    description: Functions with >50 lines"
    echo "    recommendation: Extract logic into smaller functions"
fi

# Magic numbers detection
MAGIC_NUMBERS=$(echo "$SOURCE_FILES" | while read -r file; do
    if [ -f "$file" ]; then
        grep -nE '(= |return |\(|\[)[0-9]{2,}' "$file" 2>/dev/null | grep -vE '(0|1|2|3|4|5|6|7|8|9|10|100|1000|24|60|365|200|201|204|400|401|403|404|500|502|503|3000|3001|8080|443|80)' | head -5
    fi
done | wc -l)

if [ "$MAGIC_NUMBERS" -gt 0 ]; then
    echo "  - smell: magic_numbers"
    echo "    severity: low"
    echo "    count: $MAGIC_NUMBERS"
    echo "    description: Hardcoded numeric values without named constants"
    echo "    recommendation: Extract constants into named variables"
fi

# Commented-out code detection
COMMENTED_CODE=$(echo "$SOURCE_FILES" | while read -r file; do
    if [ -f "$file" ]; then
        grep -nE '^\s*(//|#|\*)\s*(if|for|while|function|const|let|var|import|from|class|def|return|console|print)' "$file" 2>/dev/null | head -3
    fi
done | wc -l)

if [ "$COMMENTED_CODE" -gt 0 ]; then
    echo "  - smell: commented_out_code"
    echo "    severity: low"
    echo "    count: $COMMENTED_CODE"
    echo "    description: Commented-out code blocks"
    echo "    recommendation: Remove or document why code is commented"
fi

# TODO/FIXME detection
echo "todos_and_fixmes:"
TODO_COUNT=$(echo "$SOURCE_FILES" | xargs grep -h 'TODO\|FIXME\|HACK\|XXX\|BUG\|NOTE.*fix\|NOTE.*refactor' 2>/dev/null | wc -l)
if [ "$TODO_COUNT" -gt 0 ]; then
    echo "  count: $TODO_COUNT"
    echo "  severity: low"
    echo "  description: $TODO_COUNT TODO/FIXME comments found"
    echo "  items:"
    echo "$SOURCE_FILES" | xargs grep -n 'TODO\|FIXME\|HACK\|XXX\|BUG' 2>/dev/null | head -20 | sed 's/^/    - /'
else
    echo "  count: 0"
fi

# Complexity metrics
echo "complexity_metrics:"

# Cyclomatic complexity approximation (count decision points)
DECISION_POINTS=$(echo "$SOURCE_FILES" | while read -r file; do
    if [ -f "$file" ]; then
        grep -cE '(if |while |for |switch |case |catch |\?\:|&&|\|\|)' "$file" 2>/dev/null || echo 0
    fi
done | awk '{sum+=$1} END {print sum}')

echo "  total_decision_points: ${DECISION_POINTS:-0}"
if [ -n "$TOTAL_FILES" ] && [ "$TOTAL_FILES" -gt 0 ]; then
    AVG_COMPLEXITY=$((DECISION_POINTS / TOTAL_FILES))
    echo "  average_per_file: $AVG_COMPLEXITY"
fi

# Maximum complexity file
MAX_COMPLEXITY_FILE=$(echo "$SOURCE_FILES" | while read -r file; do
    if [ -f "$file" ]; then
        count=$(grep -cE '(if |while |for |switch |case |catch |\?\:|&&|\|\|)' "$file" 2>/dev/null || echo 0)
        if [ "$count" -gt 0 ]; then
            echo "$count $file"
        fi
    fi
done | sort -rn | head -1)

if [ -n "$MAX_COMPLEXITY_FILE" ]; then
    MAX_COMPLEXITY=$(echo "$MAX_COMPLEXITY_FILE" | awk '{print $1}')
    MAX_COMPLEXITY_FILE_NAME=$(echo "$MAX_COMPLEXITY_FILE" | awk '{print $2}')
    echo "  max_complexity_file: $MAX_COMPLEXITY_FILE_NAME"
    echo "  max_complexity_score: $MAX_COMPLEXITY"
    if [ "$MAX_COMPLEXITY" -gt 50 ]; then
        echo "  max_complexity_severity: high"
    elif [ "$MAX_COMPLEXITY" -gt 30 ]; then
        echo "  max_complexity_severity: medium"
    else
        echo "  max_complexity_severity: low"
    fi
fi

# Duplication detection (simple: find files with similar first 5 lines)
echo "duplication_analysis:"
DUPLICATE_PATTERNS=$(echo "$SOURCE_FILES" | while read -r file; do
    if [ -f "$file" ] && [ "$(wc -l < "$file")" -gt 10 ]; then
        head -5 "$file" | md5 2>/dev/null || head -5 "$file" | md5sum 2>/dev/null | awk '{print $1}'
    fi
done | sort | uniq -d | wc -l)

if [ "$DUPLICATE_PATTERNS" -gt 0 ]; then
    echo "  potential_duplicates: $DUPLICATE_PATTERNS"
    echo "  severity: medium"
    echo "  description: Files with identical headers - possible copy-paste"
    echo "  recommendation: Extract common logic into shared modules"
else
    echo "  potential_duplicates: 0"
fi

# Code quality score
echo "quality_score:"
SCORE=10
MAX=10

# Penalize for issues
if [ "$VERY_LARGE_FILES" -gt 0 ]; then SCORE=$((SCORE - VERY_LARGE_FILES)); fi
if [ "$LARGE_FILES" -gt 3 ]; then SCORE=$((SCORE - 1)); fi
if [ "$NESTED_FILES" -gt 5 ]; then SCORE=$((SCORE - 1)); fi
if [ "$LONG_FUNCTIONS" -gt 5 ]; then SCORE=$((SCORE - 1)); fi
if [ "$MAGIC_NUMBERS" -gt 10 ]; then SCORE=$((SCORE - 1)); fi
if [ "$COMMENTED_CODE" -gt 5 ]; then SCORE=$((SCORE - 1)); fi
if [ "$TODO_COUNT" -gt 20 ]; then SCORE=$((SCORE - 1)); fi
if [ "${MAX_COMPLEXITY:-0}" -gt 50 ]; then SCORE=$((SCORE - 2)); fi
if [ "$DUPLICATE_PATTERNS" -gt 3 ]; then SCORE=$((SCORE - 1)); fi

# Ensure score doesn't go below 0
if [ "$SCORE" -lt 0 ]; then SCORE=0; fi

echo "  score: $SCORE"
echo "  max_score: $MAX"
echo "  percentage: $((SCORE * 100 / MAX))"

# Top 10 most complex files
echo "top_complex_files:"
echo "$SOURCE_FILES" | while read -r file; do
    if [ -f "$file" ]; then
        lines=$(wc -l < "$file")
        decisions=$(grep -cE '(if |while |for |switch |case |catch |\?\:|&&|\|\|)' "$file" 2>/dev/null || echo 0)
        complexity=$((lines + decisions * 2))
        if [ "$complexity" -gt 100 ]; then
            echo "  - file: $file"
            echo "    lines: $lines"
            echo "    decisions: $decisions"
            echo "    complexity: $complexity"
        fi
    fi
done | sort -t: -k4 -rn | head -10
