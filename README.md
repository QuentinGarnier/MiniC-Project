# MiniC-Project
Projet de Compilation (L3).  
<br />

Le compilateur agit en deux passes, il doit donc agir ainsi :  
1. Il lit les fichiers .c en entrée.  
2. Première passe : il vérifie qu'il n'y a pas d'éventuelle erreur et parse le programme C en construisant une **<ins>représentation interne en mémoire<ins/>** (un arbre abstrait pour <ins>chaque</ins> fonction du programme en entrée).  
3. Deuxième passe : il parcourt la représentation interne en mémoire et génère un fichier DOT en sortie.  

Si le programme en entrée contient une erreur, le compilateur devra afficher un message d’erreur et ne générer aucun fichier DOT en sortie.  
Rappel : un arbre abstrait n’est pas un arbre syntaxique. Un arbre abstrait ne contient aucune information concernant la grammaire du langage en entrée (contrairement à un arbre syntaxique).  
