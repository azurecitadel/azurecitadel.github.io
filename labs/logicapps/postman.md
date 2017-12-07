---
layout: article
title: POostman instructions for testing the HTTP endpoint
date: 2017-12-07
categories: guides
tags: [logic, app, postman, test, http, endpoint, json, payload]
comments: true
author: Richard_Cheney
---

Postman is a tool commonly used by developers to test out REST APIs.

The instructions below can be used instea of the curl command to POST the sample JSON payload to the HTTP endpoint and make sure that we are getting a successful HTTP response of 200.  It also allows us to check the customised headers and the response body.

The video below shows Postman in action, followed by the step by step instructions.

<video video width="800" height="600" autoplay controls muted>
  <source type="video/mp4" src="/labs/logicapps/images/testHttpEndpoint.mp4"></source>
  <p>Your browser does not support the video element.</p>
</video>

* Click on the Logic App name at the top of the portal
* You will now be in the Logic App's Overview screen 
* Click on the copy icon on the right of the **Callback url [POST]** in the Trigger History pane.  This is the HTTP REST API endpoint.
* Open up the Postman app, skipping login
  * Change the action from **GET** to **POST** in the drop list 
  * Paste the HTTP REST API into the _Enter request URL_ field
  * On the Authorization tab, leave type as _No Auth_
  * On the Headers tab, add one key-value pair:
    * Key: **Content-Type**
    * Value: **application/json**

![](/labs/logicapps/images/postmanHeaders.png)  

  * On the Body tab, toggle the body type to raw
  * Open the <a href="/labs/logicapps/feedback.json" target="payload">example JSON payload</a> we saw earlier, and copy the contents to the clipboard 
  * Paste the JSON payload into Postman
  * Click on the blue **Send** button
  * The HTTP response from the Logic App should show in the bottom pane:

![](/labs/logicapps/images/postmanBody.png)

If you take a look at the headers of the response then you'll notice some standard headers, some that are associated with the Logic App itself, and also our custom header showing the ID number that we originally passed in through the sample JSON payload. 

If you want to POST again to retest, i.e. after adding Logic App workflow functionality, then you can just click on the blue POST button again.  And feel free to modify the content of the JSON payload before POSTing.