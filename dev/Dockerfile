FROM mcr.microsoft.com/devcontainers/python:3.12

USER vscode

RUN curl -fsSL https://claude.ai/install.sh | bash
ENV PATH="/home/vscode/.local/bin:${PATH}"

RUN pip install --user pytest
