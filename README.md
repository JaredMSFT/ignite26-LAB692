<p align="center">
<img src="img/banner-ignite-26.png" alt="Microsoft Ignite 2026" width="100%"/>
</p>

# [Microsoft Ignite 2026](https://ignite.microsoft.com)

## 🔥@lab.Title

### 🚀 Getting started

Sign in to your Lab VM with the following credentials:

**Username: ++@lab.VirtualMachine(Win11-Pro-Base).Username++**

**Password: +++@lab.VirtualMachine(Win11-Pro-Base).Password+++**

# Table of Contents

1. [Part 0 - Sign in to Azure and review your Azure resources](#part-0---sign-in-to-azure-and-review-azure-resources)
2. [Part 1 - Connect to your Azure HorizonDB database using VS Code Extension for PostgreSQL](#part-1---connect-to-your-azure-horizondb-database-using-vs-code-extension-for-postgresql)
    1. [Open VS Code and set up database connection to Azure PostgreSQL](#open-vs-code-and-set-up-database-connection-to-azure-postgresql)
    2. [Enter your HorizonDB Password](#enter-horizondb-password)
    3. [Explore VS Code Extension for PostgreSQL Dashboard](#explore-vs-code-extension-for-postgresql-dashboard)
3. [Part 2 and 3 - Data Setup and Agentic App Development](#part-2-and-3---data-setup-and-agentic-app-development)

---

# Part 0 - Sign in to Azure and review Azure resources

In this section, we'll open Edge browser in the lab environment and sign in to the Azure portal to review the Azure resources we will use in this lab.

1. Double-click on the **Microsoft Edge** icon on the desktop.

    ![Starting the Lab](img/0-portal.png)
    > [!NOTE]
    > If you encounter a Sign-in pop up, simply click the "Not now" button.

1. To log into the Azure Portal, enter the following credentials:

    - Username: +++@lab.CloudPortalCredential(User1).Username+++
    - TAP: +++@lab.CloudPortalCredential(User1).TAP+++

    > [!NOTE]
    > This lab uses a Temporary Access Pass (TAP) for the Azure subscription password.  If you need to access this TAP code again, use the **Resources** tab at the top of these lab instructions.

1. Once logged in to the Azure Portal, select **View all resources**.
![View all resources](img/0.1-view-all-resources.png)

1. We'll be using these resources during this lab:
    - Microsoft Foundry instance
    - Azure HorizonDB Database instance
![Azure Lab Resources](img/0.2-lab-resources.png)

---

Your HorizonDB resource has been provsioned along with a **Parameter Group** for HorizonDB containing the server parameter configuration for your Postrgres extensions and the associated allowlist details.

Parameter groups are a new concept in HorizonDB.  Parameter groups act as containers for cluster configuration values that can be applied to one or more database clusters. Instead of managing configuration settings for each cluster individually, you can define them in a parameter group and connect that group with multiple clusters to ensure consistency across your environment.  In our case, we only have one cluster in our lab, however, we need to confirm that the Parameter group has been enabled to complete the lab.

Parameter groups are first-class resources in Azure and are surfaced within the specific resource group and subscription defined in their resource identifier.

1. Click on the HorizonDB instance in the portal

1. Expand **"Settings"** in the left navigation, and click **"Parameters"**

1. Confirm that your parameter group has been enabled for your HorizonDB instance.
![HorizonDB Server Parameters](img/0.3-server-parameters.png)

===

# Part 1 - Connect to your Azure HorizonDB database using VS Code Extension for PostgreSQL

## Open VS Code and set up database connection to Azure PostgreSQL

1. Go to your desktop and double select the **VS Code** icon to open VS Code on your lab VM.

![Starting the Lab](img/1.1-vscode.png)

1. Once inside VS Code, you should be already in the **"C:\\Users\\LabUsers\\source\\repos\\ignite26-LAB692"** folder.  If not, select **File** > **Open Folder...** > Choose **"C:\\Users\\LabUsers\\source\\repos\\ignite26-LAB692"** to open this folder into your workspace

![VS Code Explorer](img/1.2-vscode-explorer.png)

1. Now, look for the Azure Postgres VS Code extension and click to open it

![Introducing the Postgres extension](img/1.3-postgres-extension.png)

1. Most of these connection details have been populated for you.  To connect to your HorizonDB instance we can click the server connection and when prompted, enter in the Lab VM **Password: +++@lab.VirtualMachine(Win11-Pro-Base).Password+++**

![Connecting to HorizonDB](img/1.4-horizondb-password.png)

> [!NOTE]
> During the lab creation process we added a firewall rule to allow IP address connections into your instance of HorizonDB. In the future, you will need to ensure you take this step to restrict network access to allow only valid network traffic to reach your HorizonDB resource.

**Congratulations, you just signed in to your Azure HorizonDB database using the VS Code Extension for PostgreSQL!**

===

## Explore VS Code Extension for PostgreSQL Dashboard

1. Now that we have our connection created, let's explore the VS Code Extension for PostgreSQL and our HorizonDB database.  First, right-click on your **"Ignite Lab HorizonDB"** connection and select the "Dashboard" option from the context menu:

![HorizonDB Dashboard](img/1.5-horizondb-dashboard.png)

1. When the Dashboard loads, you will see it provides a robust set of performance details such as **wait events, disk i/o, transactions, storage, and more**.

1. To continue exploring the VS Code Extension for PostgrSQL, now expand the **"Databases"** node under the **"Ignite Lab HorizonDB"** connection.  Look for the **"postgres"** database, right-click it and select **"New Query"** from the context menu.

![New Query](img/1.6-new-query.png)

1. Now run the following query by copying and pasting the following SQL block into the query editor window, then click the green play arrow on the top right to execute the SQL statement.  The purpose of this SQL query is just to illustrate the process of running queries and seeing results using the VS Code Extension for PostgreSQL.

During the course of this lab most SQL queries will be ran programmatically via Python code and the pscyopg Python package.  However, there are a few queries you will need to run using the query editor in the VS Code Extension, so stay tuned for those!

```SQL
SELECT
current_database() AS database_name,
current_user AS connected_user,
now() AS server_time,
version() AS postgres_version;
```

![View your Query Results](img/1.7-query-results.png)

===

# Part 2 and 3 - Data Setup and Agentic App Development

For the remainder of the lab we are going to work from two Jupyter Python Notebooks within VS Code.  All further lab instructions will be in-line within each notebook. The first notebook (1-data-setup) is a data setup notebook and the second notebook (2-app-development) is the agentic application development notebook.

These notebooks are both located in the **"C:\\Users\\LabUsers\\source\\repos\\ignite26-LAB692"** folder structure under the folder **"instructions"**:

- **1-data-setup.ipynb**
- **2-app-development.ipynb**

Additionally, there is a third, optional notebook, which is a diagnostics notebook for ensuring server settings and configurations:

- **3-diagnostics.ipynb**

## Open Notebook 1 - Data Setup

1. Within VS Code, on the left navigation bar, select the **Explorer** icon to return to the **Explorer** view.

![VS Code Explorer](img/1.2-vscode-explorer.png)

1. Expand the **instructions** folder and look for a file name **1-data-setup.ipynb**, then double-click the file.

![Jupyter Notebook](img/1.8-jupyter-notebook.png)

1. This will open the first notebook. Read each section of the notebook and follow the in-line instructions.

1. You will need to select a Jupyter notebook runtime kernel in order to execute the code blocks within the notebook.

![Kernel Runtime](img/1.9-python-runtime.png)

1. Once you have selected the appropriate python 3.11.9 kernel, you can begin to run the code blocks included within your notebooks.

![Execute Notebook Cells](img/1.10-execute-cell-notebooks.png)

>[!alert] At this point, continue the lab following the instructions in the Notebook 1 in VS Code.

### On your own

If you're learning at your own pace:

1. Clone this repository
2. Set up your environment using the [`infra/0.0-deploy-hdb.bicep file`](infra/0.0-deploy-hdb.bicep) and follow up by executing the four .ps1 PowerShell scripts.
3. Follow the instructions above to load the jupyter notebooks.

### 🎯 Learning outcomes

By the end of this session, you will be able to:

- Use HorizonDB's integrated AI model and AI pipeline features.
- Develop an agentic AI platform.
- Combine HorizonDB's AI capabilities with modern agentic application development to deploy a working proof of concept.

### 💻 Technologies used

- HorizonDB
- HorizonDB parameter groups
- HorizonDB native extensions
- Microsoft Foundry with GPT and embedding models
- Modern AI development libraries, including mem0

### 📚 Continue your learning

Pick your next step based on your learning style:

| Resource | What you'll get |
|----------|-----------------|
| **[Ignite 2026 Next Steps](https://aka.ms/ignite26-next-steps)** | Additional session repos and materials from Microsoft Ignite 2026 |
| **[Microsoft AI Skills Navigator](https://aka.ms/ignite26-asn)** | Discover AI skills, learning paths, and resources for your next step |
| **[Microsoft Learn](https://aka.ms/ignite26-learn)** | Official documentation and guided learning paths on these topics |
| **[Microsoft Foundry Community](https://aka.ms/MicrosoftFoundryDiscord-Ignite26)** | Connect with other learners and experts in our Discord community |

### 🌟 Microsoft Learn MCP Server

<!-- Remove this section if the Microsoft Learn MCP Server is not relevant to the session. -->

The Microsoft Learn MCP Server gives your AI agent direct access to Microsoft's official documentation — grounded, up-to-date answers about the topics in this session.

**GitHub Copilot CLI** — Install with:

```shell
copilot plugin install microsoftdocs/mcp
```

**VS Code** — One-click install:  
[![Install in VS Code](https://img.shields.io/badge/VS_Code-Install_Microsoft_Learn_MCP-0098FF?style=flat-square&logo=visualstudiocode&logoColor=white)](https://vscode.dev/redirect/mcp/install?name=microsoft-learn&config=%7B%22type%22%3A%22http%22%2C%22url%22%3A%22https%3A%2F%2Flearn.microsoft.com%2Fapi%2Fmcp%22%7D)

For more information, visit the [Learn MCP Server repo](https://aka.ms/learnmcp).

### 👥 Content owners

<table>
<tr>
    <td align="center"><a href="https://github.com/JaredMSFT">
        <img src="https://github.com/JaredMSFT.png" width="100px;" alt="JaredMSFT"/>
        <br />
        <sub><b>Jared Meade</b></sub></a>
        <br />
        <a href="https://github.com/JaredMSFT" title="talk">📢</a>
    </td>
</tr>
</table>

### ⚖️ Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow [Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general). Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.

Any use of third-party trademarks or logos are subject to those third-party's policies.
