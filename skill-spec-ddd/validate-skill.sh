#!/bin/bash

# Skill Validator for skill-spec-ddd
# Validates SKILL.md structure and references

set -e

echo "🔍 Skill Validator - Checking skill-spec-ddd integrity"
echo "======================================================"

ERRORS=0
WARNINGS=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to report error
report_error() {
    echo -e "${RED}❌ ERROR:${NC} $1"
    ((ERRORS++))
}

# Function to report warning
report_warning() {
    echo -e "${YELLOW}⚠️  WARNING:${NC} $1"
    ((WARNINGS++))
}

# Function to report success
report_success() {
    echo -e "${GREEN}✅${NC} $1"
}

echo ""
echo "📄 Checking SKILL.md..."
echo "------------------------"

# Check if SKILL.md exists
if [ ! -f "SKILL.md" ]; then
    report_error "SKILL.md not found"
    exit 1
fi

report_success "SKILL.md exists"

# Check YAML frontmatter
if head -1 SKILL.md | grep -q "^---"; then
    report_success "YAML frontmatter present"
else
    report_error "Missing YAML frontmatter (---)"
fi

# Check required fields in frontmatter
if grep -q "^name:" SKILL.md; then
    report_success "Name field present"
else
    report_error "Missing 'name' field in frontmatter"
fi

if grep -q "^description:" SKILL.md; then
    report_success "Description field present"
else
    report_error "Missing 'description' field in frontmatter"
fi

echo ""
echo "🔍 Checking required sections..."
echo "---------------------------------"

# Check for required phases/sections
REQUIRED_SECTIONS=(
    "Phase 1: Requirements Elicitation"
    "Phase 2: Dual-Language Analysis"
    "Phase 3: Problem Decomposition"
    "Phase 4: Architecture Decision Records"
    "Phase 5: Implementation Checklist"
    "Phase 6: Execution Framework"
    "Phase 7: Observability"
    "DDD Pattern Library"
    "Risk Matrix Reference"
    "References"
)

for section in "${REQUIRED_SECTIONS[@]}"; do
    if grep -q "##.*$section" SKILL.md; then
        report_success "Section found: $section"
    else
        report_warning "Section missing: $section"
    fi
done

echo ""
echo "🔗 Checking reference files..."
echo "-------------------------------"

# Check if references directory exists
if [ ! -d "references" ]; then
    report_error "references/ directory not found"
else
    report_success "references/ directory exists"
fi

# Check required reference files
REQUIRED_REFERENCES=(
    "event-storming.md"
    "risk-matrix.md"
    "ddd-pattern-library.md"
    "ddd-tactics.md"
    "books.md"
    "tools.md"
)

for ref in "${REQUIRED_REFERENCES[@]}"; do
    if [ -f "references/$ref" ]; then
        report_success "Reference file exists: $ref"
    else
        report_error "Missing reference file: $ref"
    fi
done

echo ""
echo "🔗 Checking internal links..."
echo "------------------------------"

# Extract all links to references/
LINKS=$(grep -oE '\[references/[^\]]+\]\([^)]+\)' SKILL.md | grep -oE 'references/[^)]+' | sort | uniq)

for link in $LINKS; do
    # Clean up the link (remove anchors)
    FILE=$(echo "$link" | sed 's/#.*$//')

    if [ -f "$FILE" ]; then
        report_success "Valid link: $link"
    else
        report_error "Broken link: $link"
    fi
done

echo ""
echo "📝 Checking YAML user story examples..."
echo "---------------------------------------"

# Check if there are YAML examples in the document
YAML_BLOCKS=$(grep -c '```yaml' SKILL.md || true)
if [ "$YAML_BLOCKS" -gt 0 ]; then
    report_success "Found $YAML_BLOCKS YAML code blocks"
else
    report_warning "No YAML code blocks found"
fi

echo ""
echo "🎯 Checking Git conventions..."
echo "-------------------------------"

# Check for Git naming conventions
