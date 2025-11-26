/*
 * 🟩 Create SQL File (5.3.1) - Problem
 * 3️ Install VS Code
 * Problem Statement
 * In this task, you will practice creating a new SQL file within your project folder using VS Code. This will help you understand how to add new files to your project.

 * Open the Int_SQL_Project project folder in VS Code.
 * For each operating system you can find the project folder:
	Mac: ~/Library/DBeaver Data/workspace6/
	Windows: %APPDATA\DBeaverData\workspace6\
 * Create a .sql file in the Scripts folder.
 * The SQL file should select everything from the customer table where the customer keys are greater than 1500.
 * Save this new file named customer_table.sql.
 * Navigate back to DBeaver and refresh (F5) if needed to view the script.
*/

SELECT *
FROM customer 
WHERE customerkey > 1500


/*
    🟩 Update Settings (5.3.2) - Problem
    3️⃣ Install VS Code
    Problem Statement
    In this task, you will practice customizing the appearance and font size of VS Code to suit your preferences. This will help you create a comfortable working environment.

    Open VS Code.
    Use the command palette to search for each setting then switch to dark mode and change the font size to 14.

    Hint
    Use the command palette. Shortcuts for both OS systems:
        Mac: CMD + Shift + p
        Windows: Ctrl + Shift + p
    Change the theme settings to dark mode.
    Update the font size to 14.
*/

/*
🟩 Use Multiple Tabs (5.3.3) - Problem
3️⃣ Install VS Code
Problem Statement
In this task, you will practice using multiple tabs in VS Code to work with several files simultaneously. This will help you manage and switch between different files efficiently.

Open the Int_SQL_Project project folder in VS Code.
Update the README.md near the bottom with the contents below.
View the formatted README.md contents in the side pane.
Finally, open customer_table.sql and README.md in separate tabs that are side by side. 

📋 Copy
## Technical Details
- **Database:** PostgreSQL
- **Analysis Tools:** PostgreSQL, DBeaver, VS Code
- **Visualization:** ChatGPT

Hint
Click on file names to open them in the editor.
Open files to the side by right clicking the file and selecting Open to the Side.

*/

/*
🟨 Search Across Files (5.3.4) - Problem
3️⃣ Install VS Code
Problem Statement
In this task, you will practice using the search functionality in VS Code to find specific text across multiple files. This will help you quickly locate information in your project.

Open the Int_SQL_Project project folder in VS Code.
Use Ctrl+Shift+F (Windows) or Cmd+Shift+F (Mac) to search for the term cohort_analysis across all files.
Hint
Use the search icon in the Activity Bar to open the search view.
*/