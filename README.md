# Elm Quickstart
This is a repository that can be cloned or copied in order to start a new basic
Elm application. It sets up the following:

* Basic HTML application with model, update, view and subscriptions.
* Small utility module used to demonstrate testing.
* npm setup to run build or tests.

To use this repository, you should follow these steps.

1. npm install -g elm

2. npm install -g elm-live

3. npm install -g elm-test

4. npm install

5. npm run test

6. npm run watch

The *watch* step will run the elm-live build process and launch the browser.
Future code changes will automatically trigger a rebuild and the browser will
live reload with your changes.

## API Keys
In order to use this repository with Algolia, you will need to add an index.html
and provide API keys. Here is an example:

```
<html>
--  <head>
      <script type="text/javascript" src="dist/bundle.js"></script>
    </head>
    <body>
      <div id="elm-app"></div>

      <script type="text/javascript">
        var elmDiv = document.getElementById('elm-app');
        var algoliaApiKey = "<API Key>";
        var algoliaApplicationId = "<Application ID>";
        Elm.Main.embed(elmDiv,
                       {
                         algoliaApiKey: algoliaApiKey,
                         algoliaApplicationId: algoliaApplicationId
                       }
                      );
      </script>
    </body>
  </html>
```


