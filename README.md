# Othello con IA en CLIPS

Este proyecto consiste en la implementación del juego de mesa Othello (Reversi) utilizando el sistema experto CLIPS. El sistema permite jugar partidas entre jugadores humanos, o en la modalidad de jugador contra máquina.

## Características Técnicas y Algoritmos
El núcleo del proyecto es el desarrollo de un jugador automático capaz de tomar decisiones inteligentes evaluando el estado del juego. 

Para la toma de decisiones, el motor de Inteligencia Artificial implementa los siguientes algoritmos de búsqueda en espacio de estados:
* **Minimax:** Evalúa recursivamente los movimientos posibles alternando entre maximizar (IA) y minimizar (oponente).
* **Poda Alfa-Beta (Alpha-Beta Pruning):** Optimización del algoritmo Minimax que poda las ramas inútiles del árbol de búsqueda para mejorar la eficiencia temporal.

## Funciones Heurísticas
La evaluación de los nodos hoja en el árbol de búsqueda se realiza mediante una combinación de heurísticas que calculan la ventaja estratégica:
* **Diferencia de fichas:** Puntúa en base a la diferencia de fichas propias frente a las del oponente.
* **Movilidad:** Evalúa la ventaja estratégica calculando la cantidad de movimientos posibles restantes.
* **Control de esquinas:** Asigna puntuación positiva extra por cada esquina dominada, al ser posiciones estables.
* **Esquinas adyacentes:** Penaliza las fichas ubicadas en posiciones adyacentes a las esquinas por el riesgo de perderlas.

## Representación del Entorno
* **Tablero Dinámico:** Representación estructurada mediante una lista lineal (multislot) adaptable a tamaños de 4x4, 6x6 y 8x8 casillas.
* **Sistema Basado en Reglas:** Uso de reglas de producción (condición-acción) para controlar el flujo de turnos, la validación de movimientos y las condiciones de victoria o empate.

## Requisitos del Sistema y Ejecución
Para ejecutar este código es necesario tener instalado el entorno de desarrollo CLIPS.

Para iniciar el juego:
1. Cargar el código fuente en el entorno.
2. Ejecutar el comando (run) en la consola.
3. Introducir los parámetros de configuración solicitados (tipo de jugadores, algoritmo, profundidad de búsqueda y tamaño del tablero).