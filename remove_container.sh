#!/usr/bin/env bash

docker stop $(docker ps -aqf "name=research_project1819")
docker rm $(docker ps -aqf "name=research_project1819")
