# API

## Labs

### PUT /submissions/:id/grade/:grade

- Assistant
  - Sätter grade på en submission

### GET /labs

- Student
  - En lista med labbar som inte är avklarade
- Assistant
  - En lista med labbar som ska rättas
- Examiner
  - En lista med alla labbar där personen är examinator
- Administrator
  - Alla labbar i applikationen

### GET /courses/:course_id/labs

- Student
  - En lista med labbar som inte är avklarade
- Assistant
  - En lista med labbar som inte är rättade
- Examiner
  - En lista med alla labbar där användaren är examinator
- Administrator
  - En lista med alla labbar för en kurs

### GET /courses/:course_id/groups/:group_id/labs

- Student
  - En lista med labbar som inte är avklarade för en grupp användaren är med i
- Assistant 
  - En lista med labbar som ska rättas för en grupp som användaren blivit tilldelad
- Examiner
  - En lista med alla labbar för en grupp användaren är examinator i
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

### POST /courses/:id/join

- Student
  - Registrerar sig på en kurs
- Assistant
  - Registrerar sig som assistent på en kurs
- Examiner
  - Registrerar sig som examiner på en kurs
- Administrator

## Groups

### GET /courses/:course_id/groups/new

### POST /courses/:course_id/groups/new

- Student
  - Skapar en grupp där studenten som skapade gruppen redan är medlem, såvida att studenten är registrerad på kursen

### GET /courses/:course_id/groups/:id

### GET /courses/:course_id/groups/:id/join

- Student
  - En lista med alla grupper, på en kurs, som en student kan gå med i, såvida att studenten är registrerad på kursen

### POST /courses/:course_id/groups/:id/join

- Student
  - Studenten går med i en grupp, såvida att studenten är registrerad på kursen.

## Submissions

### GET /courses/:course_id/submissions

- Student
  - En lista med alla submissions för alla labbar, på en viss kurs, för dom grupper som studenten varit med i.
- Assistant
  - En lista med alla submissions för alla labbar som assistenten ska rätta/har rättat på en viss kurs
- Examiner
  - En lista med alla submissions för alla labbar på en kurs där usern är examiner
- Administrator
  - En lista med alla submissions för alla labbar på en viss kurs

### GET /courses/:course_id/groups/:group_id/labs/:lab_id/submissions

- Student
  - En lista med alla submissions för en labb, som studenten har gjort
- Assistant
  - En lista med alla submissions för en lab som assistenten har rättat/ska rätta
- Examiner
 - En lista med alla submissions för en lab, på en kurs där usern är examiner
- Administrator
 - En lista med alla submissions för en lab

### POST /courses/:course_id/groups/:group_id/labs/:lab_id/submissions

- Student
  - Gör en submission på en labb för en grupp som studenten är medlem i, på en kurs där studenten är registrerad. 

### GET /courses/:course_id/groups/:group_id/labs/:lab_id/submissions/new

### GET /courses/:course_id/groups/:group_id/submissions

- Student
  - En lista med alla submissions som gjorts av en grupp, som studenten är medlem i
- Assistant
  ---
- Examiner
   - En lista med alla submissions som gjorts av grupp, på dom kurser som usern är examiner
- Administrator
  - En lista med alla submissions av en grupp

## Uploads

### GET /courses/:course_id/groups/:group_id/labs/:lab_id/uploads

- Student
  - Visar uppladdningsformuläret

## CommitRequests

### POST /repositories/:repository_id/commit_requests

- Student
  - Studenten skickar en commit-hash till en repo som är kopplad till en lab och grupp som studenten tillhör. 


##Comments

### GET /comments/:id

 - Visar ett träd med :id som root kommentar

### GET /comments/:id/edit
 - Visar en form för att redigera en kommentar 

### GET /comments/new
 - Visar en form för att skapa en ny kommentar

### PUT /comments/:id

 - Updaterar en kommentar med :id

### POST /comments/:id
 - Skapar en ny kommentar

### DELETE /comments/:id
 - Tar bort en kommentar med :id
 
### GET /comments
 - Visar alla kommentarer

## Reviews

### PUT /labs/:id/submissions/:id/reviews/:result

 :result = {
   grade: string,
   state: string
}

- Assistant
  - Uppdaterar grade och/eller state i lab_has_group som äger denna submission

- Examiner
  - Uppdaterar grade och/eller state i lab_has_group som äger denna submission
