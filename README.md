<h1 align="center">Dungeons and Developers</h1>
<h4 align="center"><b>Real-Time, Competitive Programming Game designed to test its effect on motivation and engagement for 1st year Comp Sci students. UCT Honours in Computer Science Project</b></h4>

<h2 align="center">1v1 Gamemode</h2>
<p align="center">Engage in one-on-one battles where wit and pace determine the victor. Beat each monster (easy, medium, and hard question) in the maze and claim the treasures that await at the end.</p>
<p align="center">
  <img src="ReadmeImages/UI.png" alt="UI" width="100%"/>
</p>

<table align="center">
  <tr><td align="center">• Navigate a <b>procedurally-generated maze</b>.</td></tr>
  <tr><td align="center">• Defeat <b>monsters</b> using <b>Python</b> coding challenges.</td></tr>
  <tr><td align="center">• Compete against <b>one other player</b>.</td></tr>
  <tr><td align="center"><b>• Reach the exit first to win!</b></td></tr>
  <tr><td align="center">• Simple code commands to <b>traverse the maze</b>.</td></tr>
  <tr><td align="center">• Opponent’s position updates in <b>real-time</b>.</td></tr>
  <tr><td align="center"><b>• Robust code interface</b> with syntax highlighting and detailed feedback.</td></tr>
  <tr><td align="center">• Competitive integrity ensured by <b>identical mazes and initial questions</b>.</td></tr>
  <tr><td align="center">• Players get <b>stunned</b> for incorrect submissions or hitting a wall.</td></tr>
</table>

<h3 align="center">
  <b>PLAY THE GAME <a href="https://dungeonsanddevelopers.cs.uct.ac.za">HERE!</a></b>
</h3>

<h2 align="center">Architecture</h2>

<table>
<tr>
<td width="50%" valign="top">

<h3 align="center">Server</h3>

<ul>
<li>Hosts a single game at a time.</li>
<li>Handles network connections, maze and monster generation, and position synchronizations.</li>
<li>Automatically resets itself after the game ends.</li>
</ul>

<p align="center">
  <img src="ReadmeImages/Server.png" alt="Server State Diagram" height="400"/>
</p>

</td>
<td width="50%" valign="top">

<h3 align="center">Client</h3>

<ul>
<li>Handles maze movement, animations, and music.</li>
<li>Submits code to the backend for running and testing.</li>
<li>Sends updated position to the opponent.</li>
</ul>

<p align="center">
  <img src="ReadmeImages/Client.png" alt="Client State Diagram" height="400"/>
</p>

</td>
</tr>
</table>

<h2 align="center">Research Findings</h2>
A detailed research study was conducted with a survey evaluating how students engaged with different gameplay modes and question types within the game. 29 first-year Computer Science students from the University of Cape Town participated in the study. Participants completed a comprehensive survey consisting of 17 Likert-scale questions divided across several focus areas: 
- User Engagement Scale (UES)
  - Focused Attention
  - Perceived Usability
  - Aesthetics
  - Reward
- Additional Questions
  - Value
  - Understanding
  - Engagement
  - Motivation

Overall, results were very promising. The **Value**, **Engagement**, and **Reward** metrics recorded the highest mean scores of **4.62**, **4.62**, and **4.59** respectively — indicating students found the experience highly fulfilling.

**Perceived Usability** had the lowest mean score of **3.76**, suggesting an area for future improvement (potentially addressing a few technical issues or confusion around initial game mechanics). 

Participants reported having higher motivation to solve programming problems in the game than in traditional assignments, thereby affirming the game’s core educational goal.

### 1v1 Mode Survey Results 
<p align="left">
  <img src="ReadmeImages/Graph1.png" alt="Graph of UES Results" height="300"/>
  <img src="ReadmeImages/Graph2.png" alt="Graph of Additional Questions Results" height="300"/>
</p>

| UES Metric           | Average Score |
|----------------------|--------------|
| Focused Attention     | 3.94         |
| Perceived Usability   | 3.76         |
| Aesthetics            | 4.28         |
| Reward                | 4.59         |
| Value                 | 4.62         |
| Understanding         | 4.38         |
| Engagement            | 4.62         |
| Motivation            | 4.48         |

### User‑suggested Improvements  
- Shorten move commands for faster gameplay.  
- Add real‑time error checking to the coding interface for immediate feedback.  
- Increase complexity of the maze and add more monsters for continued challenge.

<h2 align="center">Team Members</h2>

This was a group project. The contributions of the other team members are listed below.

- [Ibrahim Abdou](https://github.com/IbrahAbd): Backend, Database, and Question Generation & Submission System
- [Kai Connock](https://github.com/kcurious): 2v2 Version of the Game

<h2 align="center">University University of Cape Town (UCT) </h2>
<p align="center">Department of Computer Science</p>
<p align="center">Website: https://sit.uct.ac.za</p>
<p align="center">Email: dept@cs.uct.ac.za</p> 
<p align="center">Tel: 021 650 2663</p> 
