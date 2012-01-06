Immutability
============

As many objects as possible should be immutable, if only to guarantee
to be able to come back in the character creation history.

Allocating points from a place named A to another named B in a
character C would actually be done by creating a copy of C where there
are new object in places named A and B. This actually gives a way for
the View to know where the differences are between two Model objects,
by comparing identities of the objects in places with the same names.
