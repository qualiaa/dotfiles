import setuptools

test_requires = [
    "pytest",
    "pytest-cov",
    "flake8",
    "pylint",
    "hypothesis",
    "tox",
]

setuptools.setup(
    name="{{cookiecutter.project_name}}"
    version="0.1.0",
    author="{{cookiecutter.author}}",
    author_email="{{cookiecutter.email}}",
    description="{{cookiecutter.project_description}}"
    url="https://gitlab/{{cookiecutter.git_slug}}"
    packages=setuptools.find_packages(),
    install_requires=[
        "numpy",
    ],
    extras_require={"test": test_requires},
    classifiers=[
        "Programming Language :: Python :: 3",
        "Operating System :: OS Independent",
    ],
)
