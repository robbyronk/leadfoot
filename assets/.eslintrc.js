module.exports = {
    "env": {
        "browser": true,
    },
    "extends": [
        "eslint:recommended",
        "plugin:prettier/recommended",
        "plugin:react/recommended",
        "problems",
    ],
    "parser": "babel-eslint",
    "plugins": [
        "react"
    ],
    "settings": {
        "react": {
            "version": "16.6"
        }
    }
};