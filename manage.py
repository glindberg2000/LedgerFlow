#!/usr/bin/env python
"""Django's command-line utility for administrative tasks."""
import os
import sys
from typing import List


def check_environment_safety():
    """
    Prevent dangerous operations in production environment
    unless explicitly allowed.
    """
    if os.getenv("LEDGER_ENV") == "prod" and os.getenv("ALLOW_DANGEROUS") != "1":
        dangerous_commands = [
            "flush",
            "reset_db",
            "migrate",
            "loaddata",
            "shell",
        ]

        if len(sys.argv) > 1 and sys.argv[1] in dangerous_commands:
            sys.exit(
                "🚫 ERROR: Refusing to run potentially dangerous management "
                "commands directly in production container.\n"
                "Use safe_migrate.sh for migrations or set ALLOW_DANGEROUS=1 "
                "if you really know what you're doing."
            )


def main():
    """Run administrative tasks."""
    # Add the current directory to the Python path
    sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "pdf_extractor_web.settings")

    # Check environment safety before proceeding
    check_environment_safety()

    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed and "
            "available on your PYTHONPATH environment variable? Did you "
            "forget to activate a virtual environment?"
        ) from exc
    execute_from_command_line(sys.argv)


if __name__ == "__main__":
    main()
