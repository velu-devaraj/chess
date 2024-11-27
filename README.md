# Chess

A bare minimum Chess app in Flutter. 

## Features

- Play with another player on the same device.
- Play with a backend REST engine. Requires the Spring boot REST service to be running. See https://github.com/velu-devaraj/uci-rest that again uses an executable engine - Leela Chess engine at this time. The server configuration for browser,windows and mobile apps can be done from the settings menu on the initial screen. Press enter after every change to save.
- Let backend engine play against itself.
- Chess move rules are implemented.
 

## Limitations

- No remote player.
- Limited testing done.
- Only bestmove output from engine are played. No visualizations of top or extra search moves and scores.
- The REST service is a demo service. The engine executable may utilize the hardware best.
  - Other design options might be to build a web assembly of the engine that could be executed on the browser or other devices as a serverless application. May have limitations on threads and WebGPU if any.
- The engine tested is Leela Chess Zero https://github.com/LeelaChessZero/lc0. See to know about the backend service https://github.com/velu-devaraj/uci-rest/blob/main/uci-api/README.md
- Only double tap gestures are detected. Select the piece by double tap and drop by double tap on squares. Double tap again on the same square in case of incorrect selection. Castling is done by double tap on the Rook's square rather that the square that King moves to.
- No end of game is detected. Engine executed castling is not implemented at this time.
- Generated OCI Rest client code is included as part of this project. 