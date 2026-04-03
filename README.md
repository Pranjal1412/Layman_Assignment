# Layman – Simplified News App

Layman is an iOS app built with SwiftUI that converts complex news into simple summaries using AI. It allows users to browse and save articles.

## Features

* Latest news from multiple sources
* AI-based simplified summaries
* Search functionality
* Save articles
* Dark mode support with adaptive colors
* Haptic feedback on interactions
* Reading streaks (daily engagement tracking)
* Voice input support in chatbot

## Tech Stack

* SwiftUI
* Supabase
* NewsData.io API
* Groq API
* Kingfisher


## Setup Instructions

### 1. Clone the Repository

### 2. Open in Xcode

* Open `Layman.xcodeproj`
* Select a simulator or device
* Run the project

## Environment Configuration - IMPORTANT FOR COMPLETE FUNCTIONING OF THE APP

In Xcode:
**Product → Scheme → Edit Scheme → Run → Environment Variables**
Ensure that the environment variable names exactly match those specified below, otherwise the app will not be able to access them correctly.

### Supabase

```env
SUPABASE_URL=https://kbyeghoowqmccgsuyotk.supabase.co
SUPABASE_KEY=sb_publishable_3YkawHAzUJnhSbLBaQYaYA_cmgRGiDq
```

### News API

```env
Layman_News_Key=pub_a3e4ccef886e4f91bb835c9732833b0a
```

### AI API
To create your API key
* Step 1: go to https://console.groq.com/keys
* Step 2: Click on Create API Key
* Step 3: Set the name and expiration
* Step 4: Copy the API Key
* Step 5: paste this API key in Environment variable of Xcode **Product → Scheme → Edit Scheme → Run → Environment Variables**

PLEASE ENSURE THAT THE NAME GIVEN TO THE KEY IN ENVIRONMENT VARIABLE IS 'Layman_API_Key' for functioning of the app
```env
Layman_API_Key=your_groq_api_key
```
Used for generating simplified summaries.

---

## Author

Pranjal Shinde
B.Tech CSE

---
