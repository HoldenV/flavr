# flavr

Tinder for finding food.

# Dependencies
    These are found in the pubspec.yaml file

    **Provider** is used for simpler state management. We will use.
    **Firebase Core** supports all platforms but linux. Used for many things

# TODO
    Develop style guide (exact colors, fonts, font sizes, haptics)
    Card tapping sequence
    App Icon
    Flavr Final Logo
    Splash Screen
    Suggestion for real-world dish / restaurant dialogue
    Allowing multiple cards to be manipulated at once?
    Licensing our idea / code
    Notification dialogue
    Inbox default notifications (ie welcome notification) **preferably before video demo**
    Notifications via firebase in-app messaging (for push)
    Notifications via flutter_local_notification (for local event driven)
    New account preferences dialogue (dietary preferences, etc)
    Account friends attribute via user objects?
    Friend management dialogue
    



# CLAIMED
    **Holden**
    Implement the following User Model Attributes
    User has[
        -- the following are collected at sign in
        firebase uid (for retrieving appropriate user model object)
        -- if available, we can also get these
        email (must, I think we should only support quick sign-in methods)
        photoURL
        phoneNumber
        providerData (other sign-in methods they've used for our app. For routing all to one account)

        -- These will be manually collected by our account creation screen
        username (unique),
        first name,
        last name,
        bio,
        preferred location and radius,
        profile picture,
        dietary preferences,
        allergies,
        basic cuisine preferences (to build a jumpstart recommendations?)

        -- These will be used for internal purposes
        friends list (list of usernames),
        friend requests sent (list of usernames),
        friend requests received (list of usernames),
        notifications,
        account created time,
        last login time,
        preferred location & radius,
        favorite dishes?
    ]

    After I've implemented unique username enforcement I'll start on friends.

    **Katie**
    Account / Setting page design

    **Michael**
    Get random food cards
    Track swipes
    Swipe up
    More haptics
