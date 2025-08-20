#!/bin/bash

[ ! -f .env ] && cp .env.example .env
make env
make all