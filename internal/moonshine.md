---
layout: article
title: Moonshine Discussion Document
date: 2017-11-21
categories: null 
tags: [training, curation, paths, personalisation, events, filter]
comments: true
author: Richard_Cheney
---

{% include toc.html %}

## What is Moonshine?

> ###### Moonshine is a working name for for a project to examine how we can improve on curation and personalised filtering of training artefacts and events.  

## High Level Requirements

There is no shortage of training materials available within Microsoft, but what is lacking a platform enabling :
* **learners to define individual personas**
  * i.e. where they are and where they want to get to in various subject areas
* **generated learning paths based on the persona**
* **notification of new training artefacts and events** 
  * filtered to the persona
* **tracking of progress**
  * award of badges 

#### Core Scope

**The core scope is to generate personalised technical learning paths for the four workloads:**
1. **Modern Workplace**
2. **Business Applications**
3. **Apps & Infrastructure**
4. **Data & AI**

These aim is that a learner should be be able to filter training artefacts down to the workload, through the practice solutions and then into individual practice building blocks.

![](/internal/images/workloadBuildingBlocks.png)

They should also be able to filter based on their role and products alignment. 

![](/internal/images/workloadProductAlignment.png)

#### Stretch Scope

The stretch scope is to explore the addition of:
* Notifications and/or subscription calendars for upcoming events
* Inclusion of non-technical paths
  * Onboarding
  * Soft Skills
* Extended audience
  * Internal non-technical roles
  * External partner technical roles
* Tracking of progress
  * Transcripts
  * Badges
* Reporting

## Guiding Principles 

Improving this area is something that has been tried many times, and there are a number of projects that have failed to achieve any long term improvement.  Therefore here are a few guiding principles to give a greater chance of success:

* **Personalised Filtering**

  The platform will only be successful if a learner feels that the learning path has been successfully distilled down and tailored to meet their persona's requirement and it provides value to them.  

  This extends to any event notification, which needs to be filtered based on the persona or it risks becoming just part of the noise. 

  This could extend in the future to a recommendations engine to suggest new paths or events based on what other personas have selected.

* **DevOps Mentality**

  It is key that the technical community see some short term value from the work in terms of generating learning paths.  Therefore we will take a DevOps approach in getting a minimum viable product out there to start gaining feedback, whilst planning out the short-cycle iterative improvements so that the users see continual progress.

  It is expected that the subject matter experts will initially have to do something a little pragmatically, such as manually creating simple first draft learning paths. 
  
  Taking this approach will buy time to understand the landscape better, define and agree an appropriate longer term strategy and start to move through the incipient stages.  

* **Leverage Existing Initiatives**

  There are a number of existing sites and platforms around technical learning and enablement, and the more people discuss the topic, the more come out of the woodwork. 
  
  It makes sense to leverage those platforms if they help us to accelerate, achieve the aims faster and potentially gain a wider acceptance of the platform within Microsoft if there is sensible integration.

  The following list is not exhaustive, but includes some of the areas that will need to be examined to see if they address parts of the requirements sufficiently well, or if there are indeed opportunities for integration.  

  * http://aka.ms/myLearning
  * http://aka.ms/Campus
  * http://aka.ms/OneProfile
  * https://www.linkedin.com/learning/me
  
  For example, one potential integration point is LinkedIn Learning, which features badges from various courses.  

  It may be possible to surface learning paths within this platform as "courses" for external technical learners.  The learning paths could filter to externally accessible content, and the platform looks as if it has both tracking and completion badges.     

* **Microservices**

  It is hoped that some of the platforms will provide integration points rather than being isolated silos.  If so then there is the opportunity to break down the functional elements of a platform into separate services, e.g. a persona service, a catalog service, a pathfinder service, an events service, etc.  

  If treated as a DevOps microservice platform then this would allow faster and more agile development on a number of small and lightweight services. There would also be greater scope for integration points with other services, and future extensibility. 

  Finally, it would also work as a good conversation point with App Dev partners, especially if we make use of hot new services on the platform such as Cosmos DB, Event Grid and Functions.

* **Crowdsourcing**

  It is evident that many people see the need for a platform of this type and are willing to contribute to its success.  It's also true that collectively we have a far better awareness of the various training artefacts.  

  Therefore it makes sense to allow contributors to add classification metadata for relevant training material.  
  
  New and upcoming events could also be added in.     

* **Centrality**

  This refers to both the location and the importance of the system.

  Cloud access is a given, so that crowdsourcing can be done effortlessly at the point of knowing about new content. 

  The aim is that the platform becomes a default point of access for catalogued content, learning paths and transcripts, for both users and linked platform.   

  If that is done successfully then content creators will not need to be coerced into adding their content to the platform.  
  
  For instance, if there is an upcoming hackathon in TVP, the event organisers would want the metadata quickly added to the platform so that it reaches the right audience through the notification service.  

* **Feedback Systems**

  For users to feel engaged, there is a need for feedback systems so that poorer content is naturally weeded out.  

  Also, all content naturally ages over time and therefore the relevance diminishes until is is obsolete.  This natural lifecycle management needs to be included or the personalisation will lose effectiveness.
  
* **Curation**

  With a platform that encourages user contributions, there is a risk of sprawl.  It is recommended to include periodic curation to prune out less relevant information, cleanse the quality of the existing metadata and ensure the right level of focus is maintained.

## Key People

* Mark Margolis
* Rachel Russell (UK Readiness)
* Platforms
  * Nicola Young and Dan Baker (Partner Skills)
  * Mike Naughton (OneProfile and Campus)
  * Mairead Behan (LinkedIn Learning)
* Role Owners
  * Fadi Barghouthy (PTS)
  * Saranya Sriram (CSA-P)

The role owners define the technical credentialling required for that role within My Learning.

## Status

```
21/11 Initial draft of this discussion paper.
      Communication sent to Mike Naughton and Mairead Behan.
```