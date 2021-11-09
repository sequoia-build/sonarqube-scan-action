#!/bin/bash

set -e

if [[ -z "${SONAR_TOKEN}" ]]; then
  echo "This GitHub Action requires the SONAR_TOKEN env variable."
  exit 1
fi

if [[ -z "${SONAR_HOST_URL}" ]]; then
  echo "This GitHub Action requires the SONAR_HOST_URL env variable."
  exit 1
fi

if [[ -f "${INPUT_PROJECTBASEDIR%/}pom.xml" ]]; then
  echo "Maven project detected. You should run the goal 'org.sonarsource.scanner.maven:sonar' during build rather than using this GitHub Action."
  exit 1
fi

if [[ -f "${INPUT_PROJECTBASEDIR%/}build.gradle" ]]; then
  echo "Gradle project detected. You should use the SonarQube plugin for Gradle during build rather than using this GitHub Action."
  exit 1
fi

if [[ ! -f "${INPUT_PROJECTBASEDIR%/}sonar-project.properties" ]]; then
  echo "No sonar-projects.properties defined. Inferring sonar project key and name. Use workflow specific input args to override"
  GITHUB_ORG=$(echo ${GITHUB_REPOSITORY} | cut -d'/' -f 1)
  GITHUB_REPO=$(echo ${GITHUB_REPOSITORY} | cut -d'/' -f 2)
  ADDL_ARGS="-Dsonar.projectKey=${GITHUB_ORG} -Dsonar.projectName=${GITHUB_REPO}"
fi

unset JAVA_HOME

sonar-scanner -Dsonar.projectBaseDir=${INPUT_PROJECTBASEDIR} ${ADDL_ARGS} ${INPUT_ARGS}
