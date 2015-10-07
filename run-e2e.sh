#!/bin/bash

suites=(
    'auth'
    'public'
    'wiki'
    'admin'
    'issues'
    'tasks'
    'userProfile'
    'userStories'
    'backlog'
    'home'
    'kanban'
    'projectHome'
    'search'
    'team'
)

pg_dump -c taiga > tmp/taiga.sql

for i in ${suites[@]}
do
    protractor conf.e2e.js --suite=$i

    psql taiga < tmp/taiga.sql > /dev/null
done
