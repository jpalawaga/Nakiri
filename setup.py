#!/usr/bin/env python
from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setup(
    name='NakiriWeb',
    version='0.0.1',
    description='Hosts the backend and (probably) website for Nakirir',
    long_description=long_description,
    long_description_content_type="text/markdown",
    author='James Palawaga',
    author_email='hello@nakiri.app',
    url='https://github.com/jpalawaga/NakiriWeb',
    packages=find_packages(),
    install_requires=[
        "requests==2.22.0",
        "flask!=1.12.2",
        "gunicorn~=20.0.4",
    ],
    extras_require={
        'tests': [
            'pytest==4.6.6',
        ],
    },
    keywords='NakiriWeb',
)
