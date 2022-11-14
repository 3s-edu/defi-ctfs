# Defi CTF

Welcome to Defi CTF!

This game presents a series of challenges for you to learn about security in Defi.

## Challenges

Each challenge is a standalone challenge and their objectives may vary between stealing funds, causing unexpected behaviors or stopping the system from working altogether.

 * 1 - [Flash Pool](src/src-default/flashpool/)
 * 2 - [Clueless](src/src-default/clueless/)
 * 3 - [Free](src/src-default/free/)
 * 4 - [Flash Bank](src/src-default/flash-bank/)
 * 5 - [The Awarder](src/src-default/the-awarder)
 * 6 - [Governor](src/src-default/governor/)
 * 7 - [Double Agent](src/src-default/doubleAgent)
 * 8 - [Overcollateralized](src/src-default/overcollateralized/)
 * 9 - [Overcollateralized V2](src/src-0_6_x/overcollateralized-v2/)
 * 10 - [Stealer](src/src-default/stealer/)
 * 11 - [Safe Registry](src/src-default/safeRegistry/)
 * 12 - [Secure Vault](src/src-default/secure-vault/)

## How to Play

 * Clone the repo. Note: The repo was built with [Foundry](https://book.getfoundry.sh/). To complete the challenges, a base-level knowledge of this framework is recommended.
 * Run ```make``` to install dependencies and compile the project.
 * At any point in time, run ```make build``` to compile the project and ```make tests``` to run your exploits.

## Repo Structure and Instructions
 * ```src/``` :
    * Inside you will find a sub-directory for each challenge. This sub-directory includes a README with a description of the challenge scenario.
    * For some challenges, an attack contract is required. In this situation, you must create your attack contract file in the challenge's directory and it must be named in the following manner: ```Attack<challengeName>.sol```. Their pragma should be ^0.8.0.
 * ```test/``` :
    * This is where you will code your exploits. Inside this directory, much like ```src/```, you can find a sub-directory for each challenge.
    * Inside this sub-directory you will have a ```utils/``` folder as well as a **\<ChallengeName>.t.sol** test file.
    * In ```utils/``` you can find the setup of the test scenario, along with all the variables and contracts you will need to perform your exploit.
    * You must code you exploit in the **\<ChallengeName>.t.sol** file, just under the **// Code your exploit here** comment.

When writing the exploits. make sure to comment your code and **DO NOT CHANGE** neither the scenario setup code, nor the ```_assertions()``` function.
