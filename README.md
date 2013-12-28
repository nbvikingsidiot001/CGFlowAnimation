CGFlowAnimation v0.7.8b
=======================

Version 3.0.0 of CGFlowController. Redesigned from the ground up to incorporate iOS 7's new UIAnimationDelegate set up, UIViewControllerInteractiveTransition and incorporate storyboard segues.


Initial Work
============
Broken into three categories. Animations, Interactions with animations, and segues with custom animations.
Taking it one step further ideally separate a push/pop animation from a segue that fully transitions to the
root controller.


Animation only
==============
When transitioning with a modal segue, in the prepare for segue of the presenting controller, the destination
controller needs its transitioningDelegate set to the presenting controller. This allows the segue to have a 
full transitioning context. This is for push/pop transitions only...


Interactive Animation built on the Animation (Interchangeable Interactions?)
============================================================================
Interactive animation for push/pop needs the receiving view controller to conform to the custom interactive
delegate. If pushed with modal delegate the modal controller needs to be dismissed. I believe using a custom segue
I can redefine the root controller without any memory loss.

Using modal for push/pop change out handle dismiss with different proceed next controller.


Segue built on ^ Specialized Interactive Animation
==================================================
Segue will utilize same transition code have push pop segue or full transition segue


Naming Conventions
==================
CGFlowAnimation
that has different and varying CGFlowAnimations
that are used by CGFlowSegue and CGFlowInteractiveAnimationLeftTransition
