# Chess

A bare minimum Chess app in Flutter. 

## Features

- Play with another player on the same device.
- Play with a backend REST engine. Requires the Spring boot REST service to be running. See https://github.com/velu-devaraj/uci-rest
 

## Limitations

- No remote player.
- Limited testing done.
- Only bestmove output from engine are played. No visualizations of top or extra search moves.
- No configurable search depth or no. of nodes for the engine. 
- The REST service is a demo service and a much better option might be to build a web assembly of the engine that could be executed on the browser or other devices as a serverless application.
- The engine tested is Leela Chess Zero https://github.com/LeelaChessZero/lc0. See also to see know about the backend service https://github.com/velu-devaraj/uci-rest/blob/main/uci-api/README.md