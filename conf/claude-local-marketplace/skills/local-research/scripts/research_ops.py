#!/usr/bin/env python3
"""
Research Helper Script for Local Research Skill

This script provides utility functions for managing research files,
generating timestamps, and handling research naming conventions.
"""

import re
import sys
from datetime import datetime
from pathlib import Path


def generate_research_name(user_input: str) -> str:
    """
    Generate a descriptive research name based on user input.

    Args:
        user_input: The original user query/description

    Returns:
        A kebab-case research name
    """
    # Remove common prefixes and normalize
    input_clean = user_input.lower()
    prefixes_to_remove = [
        "analyze ",
        "investigate ",
        "research ",
        "look at ",
        "examine ",
        "study ",
        "explore ",
        "understand ",
    ]

    for prefix in prefixes_to_remove:
        if input_clean.startswith(prefix):
            input_clean = input_clean[len(prefix) :]

    # Map common patterns to descriptive names
    pattern_map = {
        "auth": "authentication",
        "api": "api",
        "db": "database",
        "ui": "user-interface",
        "ux": "user-experience",
        "perf": "performance",
        "sec": "security",
        "test": "testing",
        "config": "configuration",
    }

    # Split into words and process each
    words = input_clean.split()
    processed_terms = []

    for word in words:
        # Remove punctuation and apply pattern mapping
        word_clean = re.sub(r"[^a-z0-9-]", "", word)
        if word_clean:
            # Apply pattern mapping
            if word_clean in pattern_map:
                word_clean = pattern_map[word_clean]
            processed_terms.append(word_clean)

    # Remove duplicates while preserving order
    seen = set()
    unique_terms = []
    for term in processed_terms:
        if term not in seen:
            seen.add(term)
            unique_terms.append(term)

    # Join with hyphens and limit length
    research_name = "-".join(unique_terms)
    if len(research_name) > 80:
        research_name = "-".join(unique_terms[:5])

    return research_name or "research"


def create_research_file(research_name: str, user_query: str) -> str:
    """
    Create a new research file with timestamp and return the path.

    Args:
        research_name: The generated research name
        user_query: The original user query

    Returns:
        Path to the created research file
    """
    # Create research directory
    research_dir = Path.home() / "workspace" / "llm" / "research"
    research_dir.mkdir(parents=True, exist_ok=True)

    # Generate timestamp
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")

    # Create file path
    filename = f"{research_name}-{timestamp}.md"
    filepath = research_dir / filename

    # Create file with initial header
    with open(filepath, "w") as f:
        f.write(f"# {research_name.replace('-', ' ').title()}\n")
        f.write(f"- **Created**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"- **Research Query**: {user_query}\n\n")
        f.write("## Executive Summary\n\n")
        f.write("## Codebase Analysis\n\n")
        f.write("## Knowledge Graph Insights\n\n")
        f.write("## External Research\n\n")
        f.write("## Key Findings\n\n")
        f.write("## Recommendations\n\n")
        f.write("## Files Referenced\n\n")
        f.write("## Next Steps\n\n")

    return str(filepath)


def list_research_files() -> list:
    """
    List all research files sorted by timestamp (newest first).

    Returns:
        List of file paths sorted by modification time
    """
    research_dir = Path.home() / "workspace" / "llm" / "research"
    if not research_dir.exists():
        return []

    files = []
    for file_path in research_dir.glob("*.md"):
        files.append((file_path.stat().st_mtime, file_path))

    # Sort by modification time (newest first)
    files.sort(key=lambda x: x[0], reverse=True)
    return [file_path for _, file_path in files]


def main():
    """CLI interface for the research helper."""
    if len(sys.argv) < 2:
        print("Usage: python research_helper.py <command> [args...]")
        print("Commands:")
        print("  create <user_query> - Create new research file")
        print("  list - List all research files")
        sys.exit(1)

    command = sys.argv[1]

    if command == "create":
        if len(sys.argv) < 3:
            print("Error: create command requires user query")
            sys.exit(1)

        user_query = " ".join(sys.argv[2:])
        research_name = generate_research_name(user_query)
        filepath = create_research_file(research_name, user_query)
        print(filepath)

    elif command == "list":
        files = list_research_files()
        for file_path in files:
            print(f"{file_path}")

    else:
        print(f"Error: Unknown command '{command}'")
        sys.exit(1)


if __name__ == "__main__":
    main()
