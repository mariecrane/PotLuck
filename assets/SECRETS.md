# How to add secrets to your project

## Creating your secrets file
1. Inside of the **assets** folder (which is in the root of your project), create a file named **secrets.json**.
2. Inside of that file, create an empty block using two curly braces, like so:
```json
{

}
```
3. Place any secret strings you want to store inside of these braces in the format **"key": "value"** and separate subsequent key-value pairs with commas.
The key is just the name you give your string, and the value is whatever secret string you want to store.
```json
{
"key1": "value1",
"key2": "value2"
}
```

## Storing your API key
To add your API key as a secret, create your secrets.json file exactly as shown below **without changing anything**, except for the value of your api key:
```json
{
"apiKey": "fbaa292323937bf5c8e4fe8b798faeef"
}
```
After completing these instructions you **do not need to remove** your API key from secrets.json before pushing.
You can now leave this file as it is and push without fear, because git has been set to ignore it.
This also means you do not have to worry about accidentally having someone else's key override your own, because theirs will be ignored as well.