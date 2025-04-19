# LedgerFlow

A modern Django-based financial transaction management system with AI-powered categorization and analysis.

## Features

- **Multi-Format Support**: Handles various financial document formats
- **AI-Powered Categorization**: Intelligent transaction classification using GPT models
- **Multi-Client Support**: Manage multiple client accounts with separate configurations
- **Google Sheets Integration**: Export data to spreadsheets for analysis
- **Custom Category Management**: AI-assisted category creation and management
- **Business Context Awareness**: Industry-specific categorization

## Installation

1. Clone the repository:
```bash
git clone git@github.com:glindberg2000/LedgerFlow.git
cd LedgerFlow
```

2. Create and activate a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scriptsctivate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your API keys and settings
```

5. Run migrations:
```bash
python manage.py migrate
```

## Development

### Project Structure

```
app/
├── ledgerflow/     # Django project settings and configuration
├── client/         # Client management module
├── parser/         # Document parsing modules
├── sheets/         # Google Sheets integration
└── utils/          # Utility functions
```

### Running the Development Server

```bash
python manage.py runserver
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
