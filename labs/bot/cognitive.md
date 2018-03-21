---
layout: article
title: Azure Node Bot
date: 2018-02-28
tags: [bot, node, team services]
comments: true
author: Matt_Biggs
image:
  feature: 
  teaser: 
  thumb: 
---

# Cognitive Services

The bot now has some swagger but is still a little stupid, so we are going to add in two Cognitive Services; QnA Maker and LUIS. 

For cognitive Services need two additional Node modules, similar to the ones discussed earlier, add the following code toward the top, below var botbuilder\_azure:

```
// Added for congnitive services - add to package
var builder_cognitiveservices = require('botbuilder-cognitiveservices');
var request = require('request');
```

The _botbuilder-congnitiveservices_ module is required to use LUIS and QnA Maker, the code that integrates the services. The _request_ module handles the http requests to those services.

The code entered above calls the modules, but they are not available and need to be installed. If it is not open type CTRL-&#39; to open the terminal window, and type the following:

```
npm install botbuilder-cognitiveservices
npm install request
```

The modules will install and the package.json file, discussed in the Initial Setup, will be updated – when Team Services runs the build it will run the npm install following the package.json file, which is why we can gitignore the modules.

Add the follow code to configure the QnA and Luis services – this sets up the connection to the cognitive service and the intent dialog, builds out the qnarecognizer and LuisRecognizer.

```
// QnA Builder
var qnarecognizer = new builder_cognitiveservices.QnAMakerRecognizer({
    knowledgeBaseId: process.env.QnAKnowledgebaseId,
    subscriptionKey: process.env.QnASubscriptionKey});

// Luis Connection
var luisAppId = process.env.LuisAppId;
var luisAPIKey = process.env.LuisAPIKey;
var luisAPIHostName = process.env.LuisAPIHostName || 'westus.api.cognitive.microsoft.com';
const LuisModelUrl = 'https://' + luisAPIHostName + '/luis/v2.0/apps/' + luisAppId + '?subscription-key=' + luisAPIKey;

// var recognizer = new builder.LuisRecognizer(process.env.LuisEndPoint);
var recognizer = new builder.LuisRecognizer(LuisModelUrl);
var intents = new builder.IntentDialog({ recognizers: [recognizer, qnarecognizer] })
.onDefault((session) => {
    session.send('Sorry, I did not understand \'%s\'.', session.message.text);
});
```

You will notice we have more process.envs to handle, these will need to be added to dev.env file and the Azure portal, in the bot application settings (where the storage key was set) - for ease keep that blade open until all of the keys are entered.

Add the following to the dev.env file taking and swapping in the &lt; values &gt; where indicated:

```
process.env.QnAKnowledgebaseId='<QnAKnowledgebaseId>';
process.env.QnASubscriptionKey='<QnASubscriptionKey>';
```

To get the keys open the qnamaker.ai, select the service created for this application (if you missed it, create one now) and go to settings, take the following from the URL.

POST /knowledgebases/ **&lt; QnAKnowledgebaseId&gt;** /generateAnswer
Host: https://westus.api.cognitive.microsoft.com/qnamaker/v2.0
Ocp-Apim-Subscription-Key: **&lt;QnASubscriptionKey&gt;**

In the Azure portal add the key names as below and the values used above, also copy each one into the dev.env file in VS Code.

 QnAKnowledgebaseId  
 QnASubscriptionKey

Next are the Luis key values. Prepare the following in the .env file:

```
process.env.LuisAPIKey='<Key String value>';
process.env.LuisAppId='<LuisAPIHostName>';
process.env.LuisAPIHostName='<LuisAppId>';
```

And in the Azure portal use the key names below:

LuisAPIKey  
LuisAppId  
LuisAPIHostName

In the luis.ai portal open the app and the Publish page, scroll down to &#39;Resources and Keys&#39;. Extracting the information as detailed below, copy into the dev.env file and the Azure portal application settings.

LuisAPIKey = the Key String value

From the endpoint string extract the following:

https:// **&lt; LuisAPIHostName&gt;** /luis/v2.0/apps/ **&lt;LuisAppId&gt;**?subscription-key=6eaf6a1cafdc49618bb3ad2365d5a4ef&amp;verbose=false&amp;timezoneOffset=0&amp;q=

Save the dev.env file.

Currently the bot is looking for the root &#39;/&#39; to start the session, but it needs to listen for &#39;intents&#39; provided by the recognizers.

Add the following code for the dialog _start_, which will listen for intents, that will make more sense shortly:

```
// start to run Intents
bot.dialog('start', intents);
```

The code listens and then routes through welcome message (_profile.welcomed_ is used to track if a user is new or returning) and/or the Ensure Profile waterfall, the conversation needs to be directed from that opening to the new _start_ dialog. Edit the following to add:

```
var bot = new builder.UniversalBot(connector, [
    function (session) {
        session.beginDialog('ensureProfile', session.userData.profile);
    },
    function (session, results) {
        if (!session.userData.profile.welcomed) {
        session.userData.profile = results.response; // Save user profile.
        session.userData.profile.welcomed = 'yes';
        session.send(`Great, ${session.userData.profile.name}, I love ${session.userData.profile.animal}s!`);
        } else {
        session.send(`Welcome back, ${session.userData.profile.name}, spirit friend.`); 
        }
        session.beginDialog('start');
    }
]).set('storage', tableStorage);
```

By adding the above you are capturing the route into the bot conversations and, when done, sending it to _start_ to listen for intents.

Responses from Luis are handled individually, that is a message from a user calls Luis and that returns an intent that is handled on a one-to-one basis (will make more sense in a moment), whereas the QnA Maker returns a single result, it returns the result from the service itself. Add the code below to handle the QnA Maker response – essentially it takes the entity (object) returned from the QnA service and provides the _answer_.

```
// direct to QnA
intents.matches('qna', [
    function (session, args, next) {
        var answerEntity = builder.EntityRecognizer.findEntity(args.entities, 'answer');
        session.send(answerEntity.entity);
    }
]);
```

For this to work the Cognitive Services needs some content, the QnA Maker is empty and we need to add intents to Luis.

The QnA Maker works by serving up answers using Q&amp;A pairs, these can be entered manually, uploaded as a file, or taken from a web page that has Q&amp;As.

In **qnamaker.ai** go to the **settings** page and, in the URLs section, enter the following URL – for want of something better, a page about eating one&#39;s spirit animal (something I found on a search engine when looking for FAQ pages):

[https://www.mcsweeneys.net/articles/eating-your-spirit-animal-an-faq](https://www.mcsweeneys.net/articles/eating-your-spirit-animal-an-faq)

Click the green **Save and retrain** button and when it&#39;s done go to the Knowledge Base tab, you&#39;ll see a table with the QnA pairs, a default greeting and then those extracted from the web page. Let&#39;s also add a new QnA pair manually. Click

**+ Add new QnA pair**
 Question: Are you a bot?
 Answer: Yes! One that loves spirit animals.

Click **Save and retrain** and then **Publish** , review the changes and then **Publish**. There is the option to train the application, and refine the results to any question, which you can do if you would like, but won&#39;t cover here.

Next, train some basic Intents in Luis. In [eu.luis.ai](eu.luis.ai), in the app you created, go to the Build tab. Sticking with the spirit animal theme, click **Create new intent** , and call it _findSpirit_. In the box at the top type in some utterances, ie, what a user would type to trigger this action.

I want to locate my spirit animal  
where is my spirit animal  
I want to find my spirit animal

Create a new Intent called _spiritMeaning_ with the following utterances:

 why is my spirit animal a tiger?  
 what does it mean having a spirit animal?  
 my spirit animal is a lion, what does it mean?  
 frog spirit animal meaning  
 what does my spirit animal mean?  

In a couple of these utterances there are animals, to extract that information needs an entity. Click on Entities under App Assets and **Create new entity** , create a simple entity called _animal_. When done go back into the _spiritMeaning_ intent. On the utterances click on the word _tiger_ and select animal, repeat for _lion_, and _frog_.

Click the **Train** button. Open the **Publish** tab and click **Publish to production slot**. It is important to note that the results are limited due to the lack of proper training of the Luis app, the service can become quite granular with the right detail around intents and entities, and proper training.

To see how Luis works click on the endpoint URL, when this opens in the address bar go to the end of the URL and add:

I want to find my spirit animal

This will display the JSON returned by the app, note findSpirit as the top scoring intent. The entities would also be included in the object, as there are none for this string, it is empty.

Run the bot to see the QnA working, after the intro ask &#39;are you a bot?&#39;. If you try slight variations they should work as well, the service will even allow for some mis-spellings. Also try one of the nonsense eating spirit animal questions:

Do I have to kill my spirit animal myself?  
Is my spirit animal tied to my consciousness?  
How can I kill it if it can see what I see?

If you try any of the intents you created in Luis that won&#39;t work as there is no logic to handle the response, that being the data object you saw when entering the Luis URL in the browser.

Add the following code:

```
// Intent returned from LUIS – returns a direct response to findSpirit
intents.matches('findSpirit', [
    function (session) {
        session.send('Kerching! If you have money and want to find your spirit animal, then I\'m your bot.');
    }
]);
```

When you ask now, &#39;I want to find my spirit animal&#39;, you will get the session.send response from the above.

We now need to handle an entity match for the spirit meaning, add the following:

```
// use the entity to get the meaning of a spirit animal
intents.matches('spiritMeaning',  [
    function (session, args) {
        var spiritEntity = builder.EntityRecognizer.findEntity(args.entities,'animal');
            if (!spiritEntity) {
                session.send('You need to tell me what you\'re spirit animal is to get its meaning!');
            } else {
                session.send('A ' + spiritEntity.entity + '? Yeah, right.');
            }
        }
]);
```

The _if_ statement is used to determine a response path, based on whether there is an entity present – _!spiritEntity_ is the response for the absence of a value, else it sends a glib response about the suggested animal. Test with the following to see each version:

 What does my spirit animal mean  
 why is my spirit animal a tiger

Finally, we will finish by tidying up the responses, replace the code above with the following to steer the conversation and get the information we need:

```
// working with intents to return the meaning of an intent and entity
intents.matches('spiritMeaning',  [
    function (session, args, next) {
        var spiritEntity = builder.EntityRecognizer.findEntity(args.entities, 'animal');
            if (!spiritEntity) {
                builder.Prompts.choice(session, 'You need to tell me what your spirit animal is first:', ';tiger|lion|frog', { listStyle: 4 });
            } else {
                session.beginDialog(spiritEntity.entity + 'Meaning');
            }
        },
    function (session, results) {
         session.beginDialog( results.response.entity + 'Meaning');
    }
]);
```

The code now prompts for an animal if the entity is absent, from a list, using the prompt seen in the waterfall. To handle the result it would be possible to create a function with a series of _if } { else_ that checks the result again each animal in term and direct it to the appropriate dialog, but that is too rigid. To build in flexibility the function above calls a bot.dialog with the name &lt;animal&gt;Meaning and we call this by create a string using the entity from Luis or the prompt result appended with the word &#39;Meaning&#39; - _results.response.entity + &#39;Meaning&#39;_ - so _tiger_ maps to a dialog called, _tigerMeaning_ – the dialogs could be called using the animal name, but creating a string means that another tiger dialog, eg, tigerAction, can be added if needed, and keeps a consistent format – it is a little redundant for this exercise, but wanted to make the point. Now, add the code for the basic dialogs:

```
bot.dialog('tigerMeaning', [
    function (session) {
        session.send('It means you\'re strong like a tiger.');
        session.endConversation();
    }
]);

bot.dialog('lionMeaning', [
    function (session) {
        session.send('It means you have a long golden mane, like Aslan.');
        session.endConversation();
    }
]);

bot.dialog('frogMeaning', [
    function (session) {
        session.send('It means you don\'t need big teeth and claws to compensate.');
        session.endConversation();
    }
]);
```

Save and commit your changes.

Run the bot now and use the questions and intents that you know will trigger actions.

When developing bots think about where the same actions are performed over again and how those could be tidied up, to keep the app as small as possible. As an example of flabby coding in this bot; writing three separate dialogs for the meaning of the spirit animal:

bot.dialog(&#39;tigerMeaning&#39;, […..
]);

bot.dialog(&#39;lionMeaning&#39;, […..
]);

bot.dialog(&#39;frogMeaning&#39;, […..
]);

This could be a single function to create and send the response, using a data source to get the content. For this example we will create a JSON file in the app, but it could use an external database. The data will be referenced using the animal name.

Comment out ( **CTRL-/** ) the animal meaning intent ( _intents.matches(&#39;spiritMeaning&#39;)_ ) and dialogs mentioned above (_bot.dialog(&#39;&lt;animal&gt;Meaning&#39;)_). Creating the longhand version was mostly to illustrate the wrong way, also it can be useful to create the full script to see the format, commonality, and then cut it down.

In the Documents pane in VS Code create a file called **animals.json** – where you created the dev.env file earlier. Then click on the empty file and paste the following JSON – very basic, animal and meaning:

```
{
    "tiger": {
        "meaning": "It means you're strong like a tiger."
    },
    "lion": {
        "meaning": "It means you have a long golden mane, like Aslan."
    },
    "frog": {
        "meaning": "It means you don't need big teeth and claws to compensate for anything."
    }    
}
```

To use the above there are some _requires_ to add, put this with the other requires, near the top.

```
// Add animals.json reference
var fs = require("fs");
var contents = fs.readFileSync("animals.json");
var spiritanimal = JSON.parse(contents);
```

For the above to work we need to add in the fs module – this is for the file system and allows access to the animals JSON file.

 `npm install fs`

_var contents_ refers to the json file and _spiritanimal_ parses the JSON file into something the application can read. Add the new code for _spiritMeaning_:

```
intents.matches('spiritMeaning', [
    function (session, args) {
        var spiritEntity = builder.EntityRecognizer.findEntity(args.entities, 'animal');
            if (!spiritEntity) {
            builder.Prompts.choice(session, 'You need to give me a recognised spirit animal:', 'tiger|lion|frog', { listStyle: 4 });
            } else {
            session.send(spiritanimal[spiritEntity.entity].meaning);
            }
        },
    function (session, results) {
        session.send(spiritanimal[results.response.entity].meaning);
    }
]);
```

The above creates _spiritEntity,_ extracting the animal name from the user&#39;s response, and uses it to refer to a specific animal in the JSON file and returns the meaning for that animal. Note the session.send is slight different depending on whether this uses the entity from Luis or the user&#39;s response to the prompts. This is a very quick example and there would need to be some slight tweaking to handle errors, unknown animals, etc. It might not seem like there is much of an efficiency now, but at scale, or when you start to add other properties for the animals the efficiencies become apparent.

One last addition, to add a little glamour to our bot, is to send the animal meaning as a HeroCard, a graphical card with a title, some text, and an image. The HeroCard is created by building a new message, defining the content and sending it. The content will be built using information we have to hand:

- title = the animal, eg, frog
- text = the meaning, from the animals JSON file
- image = also from the JSON file, I will provide details below to update.

We create the variable _sanimal_ to lookup the card text and image URL and then use that to build out the HeroCard – this will be created for both scenarios; the animal name coming from Luis and through the prompt results. Hopefully, by now, the code below is starting to make some sense, do not copy yet, this is illustrative:

```
var sanimal = results.response.entity;
var msg = new builder.Message(session)
        msg.attachments([
            new builder.HeroCard(session)
            .title(sanimal)
            .text(spiritanimal[sanimal].meaning)
            .images([builder.CardImage.create(session, spiritanimal[sanimal].image)])
        ]);
```

The code for the intent _spiritMeaning_ becomes what we have below, copy this to app.js, overwriting the original code:

```
intents.matches('spiritMeaning', [
    function (session, args) {
        var spiritEntity = builder.EntityRecognizer.findEntity(args.entities, 'animal');
            if (!spiritEntity) {
            builder.Prompts.choice(session, 'You need to give me a recognised spirit animal:', "tiger|lion|frog", { listStyle: 4 });
            } else {
            var sanimal = spiritEntity.entity;
            var msg = new builder.Message(session)
            msg.attachments([
                new builder.HeroCard(session)
                .title(sanimal)
                .text(spiritanimal[sanimal].meaning)
                .images([builder.CardImage.create(session, spiritanimal[sanimal].image)])
            ]);
            session.send(msg);
            }
        },
    function (session, results) {
        var sanimal = results.response.entity;
        var msg = new builder.Message(session)
        msg.attachments([
            new builder.HeroCard(session)
            .title(sanimal)
            .text(spiritanimal[sanimal].meaning)
            .images([builder.CardImage.create(session, spiritanimal[sanimal].image)])
        ]);
        session.send(msg);
        }
]);
```

The JSON files needs to be updated to add in the image URL – these are just random ones from Bing, overwrite with the following.

```
{
    "tiger": {
        "meaning": "It means you're strong like a tiger.",
        "image": "http://www.redorbit.com/media/uploads/2016/04/tiger.jpg"
    },
    "lion": {
        "meaning": "It means you have a long golden mane, like Aslan.", 
        "image": "https://lifehopeandtruth.com/uploads/images/Tribe-of-Judah-lion.jpg"
    },
    "frog": {
        "meaning": "It means you don't need big teeth and claws to compensate for anything.", 
        "image": "http://3.bp.blogspot.com/-dlW_6A2J1-E/TXeBNwjCPNI/AAAAAAAAF1A/H7ErkJ_xaUE/s1600/frog.jpg"
    }    
}
```

Run the app now and you will see the hero card displayed when you trigger the spirit meaning intent dialog, again we are just running this one set of code rather than creating the entire thing for each animal.

To that end, there is one very cool feature within VS Code that will help to remove the unnecessary repetition of the code to create the hero card:

```
var msg = new builder.Message(session)
        msg.attachments([
            new builder.HeroCard(session)
            .title(sanimal)
            .text(spiritanimal[sanimal].meaning)
            .images([builder.CardImage.create(session, spiritanimal[sanimal].image)])
        ]);
```

This is in once where the entity contains the intent animal, and once where the user is prompted for the animal, because the code uses the _sanimal_ var it is exactly the same for each scenario.

In the top section of _spiritMeaning_, highlight the code to build the message with the hero card – as above, **do not include the var sanimal**. As shown below, you will see a light bulb icon appear, hover over this and click, **Extract to function in global scope**. Change the name to **spiritCard**.

![](/labs/bot/images/Extract_to_function.PNG)

You should now see a new function created:

```
function spiritCard(session, sanimal) {
    var msg = new builder.Message(session);
    msg.attachments([
        new builder.HeroCard(session)
            .title(sanimal)
            .text(spiritanimal[sanimal].meaning)
            .images([builder.CardImage.create(session, spiritanimal[sanimal].image)])
    ]);
    return msg;
}
```

And code you highlighted in _spiritMeaning_ is replaced with the new spiritCard function  (if you ended up with something called newFunction you can change the name manually, for neatness, just get both references), passing in the _sanimal_ variable:

`var msg = spiritCard(session, sanimal);`

Simply update the second half of _spiritMeaning_ to remove the original code (as highlighted to create the function) and replace with the single line above, hopefully leaving you with:

```
intents.matches('spiritMeaning', [
    function (session, args) {
        var spiritEntity = builder.EntityRecognizer.findEntity(args.entities, 'animal');   
            if (!spiritEntity) {
            builder.Prompts.choice(session, 'You need to give me a recognised spirit animal:', "tiger|lion|frog", { listStyle: 4 });
            } else {
            var sanimal = spiritEntity.entity;
            var msg = spiritCard(session, sanimal);
            session.send(msg);     
            }
        },
    function (session, results) {
        var sanimal = results.response.entity;
        var msg = spiritCard(session, sanimal);
        session.send(msg);     
        }
]);
```

For trying to keep this lab simple to follow, the bot is not complex, but brings together a few of the key principles of user identity, conversation flow, and cognitive services and that is as much as we are going to do with this lab. You have a basic bot that will run in the Azure portal, or in a web page iFrame. If you want to use on Skype or other channels, go to Channels in the Azure portal and follow the instructions – if you want to try the bot in Skype (personal version), open the client, and click the icon to add the bot as a contact.

![](/labs/bot/images/skypetiger.PNG) 

It's that easy! 

As a follow up to this introduction, explore the additional functionality of Luis and try building more complex entities and how to handle those in the bot - even if you build a bot service around the QnA Maker you need to add code to handle actions that fall outside of the QnA, it becomes very frustrating to the user if questions outside those in the QnA pairs are not handled, although that applies to whatever bot you make. There is a lot of documentation on the Azure website to help with your next steps, hopefully you have an idea of how it all fits together now.

If you want to look at a functions bot the code should work the same this web bot, although I have not tested this. The main difference will be the file structure, the modules are not in the root folder, so setup git in the root folder of the project but navigate to the folder with the index.js file to run the bot.