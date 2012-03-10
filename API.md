# API

## Labs

### GET /labs

- Student
  - En lista med labbar som ska göras/gjorts
- Assistant
  - En lista med labbar som ska/är rättas/rättade
- Examiner
  - En lista med alla labbar på alla kurser där han är examiner
- Administrator
  - Alla labbar i applikationen

### GET /courses/:course_id/labs

- Student
  - En lista med labbar på en viss kurs som ska göras/gjorts
- Assistant
  - En lista med labbar på en viss kurs som ska/är rättas/rättade
- Examiner
  - En lista med alla labbar på en viss kurs
- Administrator
  - en lista med alla labbar på en viss kurs

### GET /courses/:course_id/groups/:group_id/labs

- Student
  - En lista med labbar som en student ska göra/gjort med en viss grupp
- Assistant 
  - En lista med labbar som ska/är rättas/rättade för en grupp som blivit tilldelade assistenten
- Examiner
  - En lista med alla labbar för en grupp
- Administrator
  - Alla labbar för en viss grupp
## Courses

### GET /courses/:id/join

- Student
  - En lista med kurser som studenten kan registrera sig på
- Assistant
  - En lista med kurser som usern kan registrera sig som assistent på
- Examiner
  - En lista med alla kurser där usern kan registrera sig som examiner på
- Administrator
 ---

### POST /courses/:id/join

- Student
  - Registrerar sig på en kurs
- Assistant
  - Registrerar sig som assistent på en kurs
- Examiner
  - Registrerar sig som examiner på en kurs
- Administrator
 ---

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
