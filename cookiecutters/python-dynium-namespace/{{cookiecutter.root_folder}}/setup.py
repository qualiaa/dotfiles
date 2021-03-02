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
    name="dynium-{{cookiecutter.project_name}}",
    description="{{cookiecutter.project_description}}",
    version="0.1.0",

    author="{{cookiecutter.author}}",
    author_email="{{cookiecutter.email}}",
    url="https://gitlab/{{cookiecutter.git_slug}}",

    packages=setuptools.find_namespace_packages(include=['dynium.*']),
    install_requires=[
        "numpy",
    ],
    extras_require={"test": test_requires},
    classifiers=[
        "Programming Language :: Python :: 3",
        "Operating System :: OS Independent",
    ],
)
