The goal of this challenge was to start managing the project using Git and GitHub following a more realistic development workflow.

This included:
- Hosting the project in a GitHub repository.
- Using branches instead of committing directly to the `main` branch.
- Creating pull requests to review changes before merging.
- Configuring a continuous integration workflow using GitHub Actions.

A feature branch (`feature/ci-pipeline`) was created to implement the CI workflow. A pull request was then opened to merge the changes into the main branch, allowing GitHub actions to automatically validate the project before merging.

---
# Continuous integration

A GitHub actions workflow was added under:

```
.github/workflows/ci.yml
```

The workflow is automatically triggered when:
- Code is pushed to any branch.
- A pull request targeting the main branch is opened or updated.

The pipeline performs the following steps:
- Checks out the repository.
- Sets up the Python environment.
- Installs the project dependencies.
- Executes the automated test using Pytest.

This ensures that every change is automatically validated before being merged into the main branch.



