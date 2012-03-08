# API

## Labs

## GET /labs

- Student
  - En lista med labbar som ska göras/gjorts
- Assistant
  - En lista med labbar som ska/är rättas/rättade
- Administrator
  - Alla labbar i applikationen

### GET /courses/:course_id/labs

## GET /courses/:course_id/groups/:group_id/labs

## Courses

### GET /courses/:id/join

### POST /courses/:id/join

## Groups

### GET /courses/:course_id/groups/new

### POST /courses/:course_id/groups/new

### GET /courses/:course_id/groups/:id/join

### POST /courses/:course_id/groups/:id/join

## Submissions

### GET /courses/:course_id/submissions

### GET /courses/:course_id/groups/:group_id/labs/:lab_id/submissions

### POST /courses/:course_id/groups/:group_id/labs/:lab_id/submissions

### GET /courses/:course_id/groups/:group_id/labs/:lab_id/submissions/new

### GET /courses/:course_id/groups/:group_id/submissions

## Uploads

### POST /courses/:course_id/uploads

## CommitRequests

### POST /repositories/:repository_id/commit_requests