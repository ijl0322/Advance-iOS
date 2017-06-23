# The Polar Adventure

The Polar Adventure is an interacitve story book designed to run on iPads. 
It is a heart warming story about a lost, lonely penguin befriending a shark, and the two continues on a fun adventure. 

## Technologies

The Polar Adventure was designed to display nicely on all iPads. Since there are a lot of very precise animations, it is difficult to use stackview/ autolayout. For this project, everything is dynamically sized and positioned depending on the user's screen size. 

For instance, the iceberg in the story book is never stretched to fit the screen. It's width is always the same as the screen's width. Using this technique, the image will most likely not fill the entire screen, so another image (of the sky and ocean of the exactly same color as the iceberg's background) is stretched to fill the screen, giving an illusion that it is the same image. 

The size of each image in the story book depends on the size of the screen. The penguin's width is always 0.15 of the screen, and the shark's width is always 0.3 of the screen. This gives me a way to animate the characters very preceisely. In page four of the story, the shark hits the tip of the iceBerg, causing the iceberg to shake. The animation will not be believable if the shark did not hit the tip correctly, even if it is only a few pixels away. However, I know that the iceberg tip will always be at x: 0.5 * screenWdith + 0.47 the width of the shark. Thus, the shark can always hit the iceberg regardless of the user's screensize. 

## Easter Eggs

The ocean is a place full of surprises, so I wanted to give the user that kind of experience in my app. 
There are several easter eggs in my app:

1. The little penguin on the home screen will walk left and right when the user swipes left/right.

2. On page 1, a narwhale will swim out when the user taps the ocean 3 times.

3. On page 7, a beluga will swim out when the user taps the ocean 3 times.


## Attributions

http://stackoverflow.com/questions/1429571/how-to-stop-nstimer-event
https://www.youtube.com/watch?v=oX9o-DnMHsE
http://stackoverflow.com/questions/24003191/pick-a-random-element-from-an-array
http://www.appcoda.com/ios-programming-animation-uiimageview/
http://stackoverflow.com/questions/37819903/ios-layer-animation-explanation
http://ronnqvi.st/controlling-animation-timing/
http://liujinlongxa.com/2016/07/10/%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3CoreAnimation%E7%9A%84fillMode%E5%92%8CisRemovedOnCompletion/
http://stackoverflow.com/questions/990221/multiple-lines-of-text-in-uilabel
https://www.bignerdranch.com/blog/uidynamics-in-swift/
https://www.raywenderlich.com/76147/uikit-dynamics-tutorial-swift
https://www.raywenderlich.com/94719/uikit-dynamics-swift-tutorial-tossing-views