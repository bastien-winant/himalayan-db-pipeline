# Himalayan Database Modeling
## Overview
### Objective
The aim of this project is to create a suite of analytics-ready datasets from the __Himalayan Database__ that allow users to answer questions about past Himalayan climbing expeditions.

It supports analytical work by processing and transforming a raw dataset into a cleaned subject-oriented data warehouse.

### What are we trying to measure
#### Scope
The focus of the project is on __expeditions outcomes, and the factors that influence them__. To this end, the datasets are built around a specific set of entities, events, and metrics of interest. Using simple queries, users are able to uncover patterns relating specific event types (e.g. expedition success, climber injury) and related factors (e.g. climbing season, route followed, climber age).

The following are examples of questions that the datasets are designed to answer:
- _what is the expedition success rate on a given route?_
- _how many expeditions have been attempted to a given peak?_
- _how long is an expedition to a given peak expected to last?_
- _does member experience impact expedition success rate?_
- _does a given route have a significantly high fatality rate?_

#### Key variables
Below is an non-exhaustive list of the principal facts and dimensions of interest of this project.

*Entities*
- expeditions
- peaks
- routes

*Events*
- ascents
- summits
- accidents

*KPIs*
- success rate
- time-to-summit
- fatality rate

*Confounding variables*
- weather
- oxygen use
- climber experience
- team composition
- sponsorship

## Data Source
### Format
The data source for this project is _The Himalayan Database_, a periodically updated public archive of Himalayan climbing expeditions. It is distributed as a set of downloadable static files via [the publisher's website](https://thehimalayandb.com).

The file type used is __DBF (DataBase File)__, a tabular binary database format introduced for the dBASE platform. In this project, the files are ingested programatically using Python's [__dbfread__ library](https://dbfread.readthedocs.io).

Despite coming in tabular format, the raw data has several deficiencies flaws that makes it unfit to support analytics workloads:
- non-atomic values
- inconsistent data types
- free-form unstructured text
- no primary keys
- empty columns

### Granularity

### Freshness
### Publisher