# Binary Heap Implementation for zeek

# $Id: BinaryHeap.bro,v 1.6 2019/02/20 19:34:38 melland Exp melland $

module BinaryHeap;

export {
	type Item: record {
		key: string &optional;
		val: double &optional;
	};

	type Heap: record {
		heap: table[count] of Item;	# The binary heap itself
		idx: table[string] of count;	# map of key to location in binary heap
		cmp: function(a: double, b:double): double;
	};

	global Init: function(cmp: function(a: double, b:double): double): Heap;
	global MinHeap: function(): Heap;
	global MaxHeap: function(): Heap;
	global Add: function(a: Heap, var: Item): bool;
	global Modify: function(a: Heap, var: Item): bool;
	global Update:function(a: Heap, var: Item);
	global Delete: function(a: Heap, var: Item): bool;
	global Peek: function(a: Heap): Item;
	global Root: function(a: Heap): Item;
	global RootAndAdd: function(a: Heap, var: Item): Item;
	global IsIn: function(a: Heap, var: Item): bool;
	global Size: function(a: Heap): count;
	global Value: function(a: Heap, var: Item): Item;

}

function printheap(a:Heap)
	{
	local i = 1;
	while (i <= |a$heap|)
		{
		print i, a$heap[i];
		++i;
		}
	}

function Init(cmp: function(a: double, b:double): double): Heap
	{
	local a: Heap;
	a$heap = table();
	a$idx = table();
	a$cmp = cmp;
	return a;
	}

function MinHeap(): Heap
	{
	return Init(function(a:double, b:double):double {return b-a;});
	}

function MaxHeap(): Heap
	{
	return Init(function(a:double, b:double):double {return a-b;});
	}

function Swap(a:Heap, i:count, j:count)
	{
	#print "Before Swap",a$heap[i],"with",a$heap[j];
	#printheap(a);
	# Update Map
	a$idx[a$heap[i]$key] = j;
	a$idx[a$heap[j]$key] = i;
	# & swap items
	local t = a$heap[j];
	a$heap[j] = a$heap[i];
	a$heap[i] = t;
	#print "After Swap";
	#printheap(a);
	}

function BubbleUp(a:Heap, k:count)
	{
	#print "Before BubbleUp",k,"=",a$heap[k]$val;
	while (k > 1 && a$cmp(a$heap[k/2]$val, a$heap[k]$val) < 0.0)
		{
		#print "BubbleUp, swapping ",k,"=",a$heap[k]$val,"with",k/2,"=", a$heap[k/2]$val;
		Swap(a, k, k/2);
		k = k/2;
		}
	#print "After BubbleUp";
	#printheap(a);
	}

function SinkDown(a:Heap, k:count)
	{
	#print "SinkDown",a$heap,k;
	local N = |a$heap|;
	while (2*k <= N)
		{
		local j = 2*k;
		if (j < N && a$cmp(a$heap[j]$val, a$heap[j+1]$val) < 0.0)
			++j;
		if (! (a$cmp(a$heap[k]$val, a$heap[j]$val) < 0.0))
			break;
		#print "SinkDown, swapping ",k,"=",a$heap[k]$val,"with",j,"=", a$heap[j]$val;
		Swap(a, k, j);
		k = j;
		}
	}

function Add(a: Heap, var: Item): bool
	{
	if (var$key in a$idx)	# Item in index....
		return F;
	local loc = |a$heap| + 1;
	a$heap[loc] = var;
	a$idx[var$key] = loc;
	BubbleUp(a, loc);
	return T;
	}

# Modify var$key to new value var$val
function Modify(a: Heap, var: Item): bool
	{
	if (var$key !in a$idx)	# Item not in index....
		return F;
	local i = a$idx[var$key];	# location in heap
	a$heap[i]$val = var$val;

	# Move up as far as it will go, then down
	BubbleUp(a, i);
	SinkDown(a, a$idx[var$key]);	# index may have changed,so we need to lookup again
	return T;
	}

# Update var$key with var$val (add or subtract to current, or add if not already in heap)
function Update(a: Heap, var: Item)
	{
	# If not already in heap, just add
	if (Add(a, var))	return;
	local i = a$idx[var$key];	# location in heap
	local c = a$heap[i]$val;	# current value
	Modify(a, [$key = var$key, $val = c+var$val]);
	}

function Delete(a: Heap, var: Item): bool
	{
	local key = var$key;
	if (key !in a$idx)	# Item not in index....
		return F;
	local i = a$idx[key];	# location in heap
	local sz = |a$heap|;
	delete a$idx[key];
	if (i == sz)	# If last item in heap
		{
		delete a$heap[sz];
		return T;
		}
	# Move last Item to slot of deleted Item
	a$heap[i] = a$heap[sz];
	key = a$heap[i]$key;		# Key of slot
	a$idx[key] = i;
	delete a$heap[sz];		# remove last Item

	# Move to correct location, go up as far as possible, then down.
	BubbleUp(a, i);
	SinkDown(a, a$idx[key]);	# Loc may have changed, so lookup again
	return T;
	}

function Peek(a: Heap): Item
	{
	local retval: Item;
	if (|a$heap| == 0)
		retval = [];
	else
		retval = a$heap[1];
	return retval;
	}

function Root(a: Heap): Item
	{
	local retval: Item;
	if (|a$heap| == 0)
		retval = [];
	else
		{
		retval = a$heap[1];
		Delete(a, retval);
		}
	return retval;
	}

# This function combines Root with Add, in a more efficient implementation
function RootAndAdd(a: Heap, var: Item): Item
	{
	local retval: Item;
	if (|a$heap| == 0)
		{
		retval = [];
		Add(a, var);
		}
	else
		{
		retval = a$heap[1];
		delete a$idx[retval$key];
		# Replace Root with new item
		a$heap[1] = var;
		a$idx[var$key] = 1;
		# ... and sink down to its proper place
		SinkDown(a, 1);
		}
	return retval;
	}


function IsIn(a: Heap, var: Item): bool
	{
	if (var$key in a$idx)
		return T;
	return F;
	}

function Size(a: Heap): count
	{
	return |a$heap|;
	}

function Value(a: Heap, var: Item): Item
	{
	if (var$key in a$idx)
		return a$heap[a$idx[var$key]];
	return [];
	}
