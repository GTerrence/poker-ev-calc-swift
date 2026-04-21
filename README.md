# Texas Hold'em EV Calculator (Monte Carlo Simulation)

**Note to reviewers:** *This is an archival project built during a 2-week personal challenge at the Apple Developer Academy. It represents my early journey into software engineering. I am keeping it in its original state as a benchmark of my growth, but I have included a detailed architectural retrospective below on how I would rebuild this system today.*

## 📌 The Concept & The "Why"
This is a native iOS application (UIKit, 100% Swift Standard Library) designed to calculate the Expected Value (EV) of a Texas Hold'em poker hand. 

Given the strict 2-week deadline of the challenge, writing an exhaustive combinatorial probability solver from scratch was unfeasible. At the time, I was unfamiliar with the formal term "Monte Carlo simulation." However, relying on the Law of Large Numbers, I hypothesized that if I simulated the remaining deck distribution uniformly thousands of times, the empirical win rate would converge on the true mathematical probability. 

I empirically tested different iteration counts and found that diminishing returns on accuracy hit at roughly 100,000 iterations. The simulation is hardcoded to execute 100,000 random runouts per calculation to balance speed and accuracy.

## 🛠 How It Works
The app uses a Form-based UIKit interface where the user inputs the known variables:
* **Hero's Hand:** The 2 hole cards.
* **Community Cards:** The flop, turn, or river (if any).
* **Villain's Range (Pseudo):** Because building a true hand-matrix range selector was out of scope, the user inputs multiple predicted card pairs for the villain.
* **Pot Dynamics:** Current pot size and the required bet size.

**Output:** The app simulates 100,000 runouts, determines the win/loss/tie percentages, and outputs the final Expected Value (EV) to dictate whether the bet is mathematically profitable.

## ⚠️ Engineering Retrospective: What I Would Change Today
This codebase is a product of its time and constraints. If I were architecting this system today for production, I would drastically overhaul the following:

1. **Hand Evaluation Logic (The `if/else` Problem):** * **Current State:** Hand strength is evaluated using massive, linear `if/else` blocks (e.g., checking for a Straight Flush down to a High Card step-by-step). 
   * **Modern Approach:** This is highly inefficient. Today, I would implement pre-computed lookup table (like the Cactus Kev algorithm) to evaluate hand strengths in $O(1)$ time. 

2. **Concurrency & Threading:**
   * **Current State:** The 100,000 iterations run synchronously. I put a loading screen over the UI, but it still blocks the main thread.
   * **Modern Approach:** I would offload the simulation to a background queue using Grand Central Dispatch (GCD) or Swift Concurrency (`async/await`), keeping the UI thread unblocked and responsive.

3. **Performance & Data Structures:**
   * **Current State:** The simulation relies on standard arrays and linear OOP structures that I was just beginning to learn, resulting in unnecessary memory overhead during shuffling and dealing.
   * **Modern Approach:** I would utilize flat arrays or matrices and perform vectorized operations where possible, stripping away heavy object allocations inside the hot loop.

4. **UI & Range Inputs:**
   * **Current State:** Asking the user to input specific villain pairs is terrible UX for poker players. 
   * **Modern Approach:** I would implement a standard 13x13 poker range grid, allowing the user to select percentages of hands, and weight the Monte Carlo selection pool accordingly.

## 🚀 How to Run Locally
1. Clone the repository.
2. Open the `.xcodeproj` file in Xcode.
3. Build and run on an iOS Simulator (Target iOS 15.0+). No third-party dependencies or CocoaPods are required.

