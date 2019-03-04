# BinaryHeap

The goal of this package is to provide a binary heap package for Zeek that can be used in multiple applications:

	Priority queue: can be efficiently implemented using a binary heap in O(logn) time.
	Incremental sorting: can be performed using a binary heap.
	Order Statistics: efficiently find the kth smallest (or largest) elements in an array.

This implementation includes the following main functions:
Create Heap with compare function
	Built in MinHeap & MaxHeap functions
Add to Heap
Delete from Heap
Modify Item in Heap
Return root of Heap
Peek at root
Replace root with new item and rebalance.

And a number of utility functions
Size of Heap
Return value of specific item by key
Determine if item by key is in Heap

Data structures & Functions

Basic user item:

```
type Item: record {
    key: string &optional;
val: double &optional;
};
```

The heap definition:

```
type Heap: record {
heap: table[count] of Item;     # The binary heap itself
               idx: table[string] of count;    # map of key to location in binary heap
               cmp: function(a: double, b:double): double;
};
```

Create a Heap:

```
Init: function(cmp: function(a: double, b:double): double): Heap;
```
This function returns an empty Heap record, initialized.  cmp is the comparison function to determine whether to swap items.  Not usually used.
 
```
MinHeap: function(): Heap;
```
This calls Init with an appropriate cmp() function that structures the Heap as a MinHeap.

```
MaxHeap: function(): Heap;
```
Creates a MaxHeap ala MinHeap

```
Add: function(a: Heap, var: Item): bool;
```
Adds an Item to Heap, returns F if var$key already exists, T upon success

```
Modify: function(a: Heap, var: Item): bool;
```
Modifies an Item already in Heap to var$val, returns F if var$key doesn’t exist, T upon success

```
Update:function(a: Heap, var: Item);
```
Updates or adds an Item in heap.  If var$key exists, add var$item to current value,
Otherwise add Item to Heap

```
Delete: function(a: Heap, var: Item): bool;
```
Delete Item var$key from Heap, var$val unused.  Return T is var$key was in Heap, otherwise F

```
Peek: function(a: Heap): Item;
```
Returns Item at root of Heap, without deleting from Heap, or empty Item if Heap is empty

```
Root: function(a: Heap): Item;
```
Returns Item at root of Heap, and deletes it from Heap, or empty Item if Heap is empty

```
RootAndAdd: function(a: Heap, var: Item): Item;
```
This function combines in an efficient way the Root() function, and the Add() function

```
IsIn: function(a: Heap, var: Item): bool;
```
Returns T or F depending on whether var$key is in the heap

```
Size: function(a: Heap): count;
```
Returns number of Items in Heap

```
Value: function(a: Heap, var: Item): Item;
```
Returns Item that corresponds to var$key, or empty Item if non-existant


Usage Example

```
event bro_init()
	{
	# Randomize
	srand(double_to_count(time_to_double(current_time())));

	# Initialize a MinHeap

	local MyHeap = BinaryHeap::MaxHeap();
	local item:BinaryHeap::Item;

	# Lets add random values & keys
	local i=1000;
	while (i > 0)
		{
		item = [$val=rand(100000) + 0.0, $key=md5_hash(rand(1000000))];
		BinaryHeap::Add(MyHeap, item);
		--i;
		}

	# Now print them out, highest first
	while (BinaryHeap::Size(MyHeap) > 0)
		{
		item=BinaryHeap::Root(MyHeap);
		print item;
		}
	exit(0);
	}
```


