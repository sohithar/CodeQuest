# CodeQuest - Programming Learning Game

HTML + CSS + JSP (scriptlets only, **no JSTL, no EL**) + Servlets + JDBC + MySQL  
JDK 17 - Apache Tomcat 10.1 (Jakarta EE 10, `jakarta.servlet.*`) - Eclipse IDE

---------------------------------------------------------------------
## 1. Create the database
1. Start MySQL 8.x.
2. Run the script:
   - Command line: `mysql -u root -p < database/codequest_db.sql`
   - or MySQL Workbench: File -> Open SQL Script -> run all.
3. This creates `codequest_db` with tables `users`, `admins`, `missions`, `mission_submissions`,
   one default admin and 9 sample questions.

**Default admin:** username `admin` / password `admin123`

## 2. Set your MySQL username & password
Open `src/main/webapp/WEB-INF/web.xml` and change the context-params
`db.user` and `db.password` (default: `root` / `root`).

## 3. Import into Eclipse (Dynamic Web Project)
1. Unzip `CodeQuest.zip`.
2. In Eclipse: **File -> New -> Dynamic Web Project**
   - Project name: `CodeQuest`
   - Target runtime: *Apache Tomcat v10.1* (New Runtime... if not listed)
   - Dynamic web module version: **6.0**   (Java: JDK 17)
   - Finish. (Do **not** tick "Generate web.xml" - ours is provided.)
3. Copy from the unzipped folder into the new project:
   - `src/main/java/com`  ->  project `src/main/java`
   - everything inside `src/main/webapp/`  ->  project `src/main/webapp`
     (`css`, `includes`, `WEB-INF`, `index.html`, all `.jsp`). Overwrite `web.xml` if asked.
4. Download **mysql-connector-j-8.x.x.jar** and put it in `src/main/webapp/WEB-INF/lib`
   (https://dev.mysql.com/downloads/connector/j/ -> Platform Independent).
5. Right-click project -> **Refresh**, then **Project -> Clean...**
6. Right-click project -> **Run As -> Run on Server** -> Tomcat 10.1.
7. Open: **http://localhost:8080/CodeQuest/**

(Alternative: it is also a normal Maven project - `pom.xml` is included - `mvn package` builds `CodeQuest.war`.)

## 4. Test the full workflow (Module 12)
1. Home page -> **Register** a student (e.g. `ramu`, `ramu@mail.com`, `123456`).
2. **Student Login** -> tick "Remember my username" (cookie) -> Dashboard opens (0 XP, Level 1).
3. Logout. Open **Admin Login** -> `admin / admin123` -> Admin dashboard.
4. **Add Question** (Java / SQL / DSA) -> **View Questions** shows it instantly.
5. Logout, log in as the student -> **Missions** -> answer a question.
   - Correct: +XP, level increases every 100 XP. Wrong: feedback, no XP.
   - Answering the same mission again is blocked (one attempt only).
6. **Leaderboard** shows ranks (top 3 get medals) and refreshes automatically.
7. Try opening `/CodeQuest/dashboard.jsp` while logged out, or `/CodeQuest/add-question.jsp`
   as a student -> you are redirected to the login page with a message.

## 5. Where each requirement is implemented
| Requirement | Where |
|---|---|
| Common CSS / dark theme | `css/style.css` |
| JDBC + PreparedStatement, reusable class | `DBConnection.java` (config read from web.xml) |
| Sessions (student: `userId`,`username`; admin: `adminId`,`adminName`) | `LoginServlet`, `AdminLoginServlet`, `*LogoutServlet` (`session.invalidate()`) |
| Access protection | `StudentAuthFilter`, `AdminAuthFilter` (+ checks at top of each JSP) |
| ServletConfig | `AdminLoginServlet` - init-param `adminSessionTimeoutMinutes` |
| ServletContext | `AppInitListener` (context-params, `xpPerLevel`, login counter), shown on Admin dashboard |
| Cookies | `LoginServlet` sets `cq_username`, `login.jsp` reads it |
| RequestDispatcher forward | Dashboard/Mission/ViewQuestions/SubmitAnswer servlets -> JSP |
| Redirects | after login, logout, registration, add question, delete |
| Transaction (submission + XP update) | `SubmitAnswerServlet` (`setAutoCommit(false)`, commit / rollback) |
| One attempt per mission | check in servlet + `UNIQUE(user_id, mission_id)` in DB |
| Correct answer hidden from students | `MissionServlet` never selects `correct_answer` |
| Validation / DB error messages | shown on the same pages (no separate error pages) |
| No JSTL / EL | scriptlets only; EL disabled in `web.xml` |

## 6. Level rule
`level = totalXP / 100 + 1` (change `xpPerLevel` in `web.xml`).

## 7. Troubleshooting
- **"No suitable driver" / driver not found** -> the MySQL connector jar is missing from `WEB-INF/lib`.
- **"Access denied for user"** -> fix `db.user` / `db.password` in `web.xml`.
- **"Unknown database codequest_db"** -> run the SQL script first.
- **404 on every page** -> make sure the runtime is Tomcat **10.1** (not 9) and the module version is 6.0.
- After changing `web.xml`, restart the server.

---------------------------------------------------------------------
## EASY WAY: Docker (no Eclipse / Tomcat / MySQL install needed)
1. Install Docker Desktop and start it.
2. Open a terminal in this folder and run:  `docker compose up --build`
3. Wait until you see "Server startup" (first time takes a few minutes), then open **http://localhost:8080/**
4. Admin login: `admin / admin123`.  Stop with Ctrl+C.  Reset all data: `docker compose down -v`
