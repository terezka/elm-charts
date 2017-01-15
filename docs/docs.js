
(function() {
'use strict';

function F2(fun)
{
  function wrapper(a) { return function(b) { return fun(a,b); }; }
  wrapper.arity = 2;
  wrapper.func = fun;
  return wrapper;
}

function F3(fun)
{
  function wrapper(a) {
    return function(b) { return function(c) { return fun(a, b, c); }; };
  }
  wrapper.arity = 3;
  wrapper.func = fun;
  return wrapper;
}

function F4(fun)
{
  function wrapper(a) { return function(b) { return function(c) {
    return function(d) { return fun(a, b, c, d); }; }; };
  }
  wrapper.arity = 4;
  wrapper.func = fun;
  return wrapper;
}

function F5(fun)
{
  function wrapper(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return fun(a, b, c, d, e); }; }; }; };
  }
  wrapper.arity = 5;
  wrapper.func = fun;
  return wrapper;
}

function F6(fun)
{
  function wrapper(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return fun(a, b, c, d, e, f); }; }; }; }; };
  }
  wrapper.arity = 6;
  wrapper.func = fun;
  return wrapper;
}

function F7(fun)
{
  function wrapper(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return fun(a, b, c, d, e, f, g); }; }; }; }; }; };
  }
  wrapper.arity = 7;
  wrapper.func = fun;
  return wrapper;
}

function F8(fun)
{
  function wrapper(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) {
    return fun(a, b, c, d, e, f, g, h); }; }; }; }; }; }; };
  }
  wrapper.arity = 8;
  wrapper.func = fun;
  return wrapper;
}

function F9(fun)
{
  function wrapper(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) { return function(i) {
    return fun(a, b, c, d, e, f, g, h, i); }; }; }; }; }; }; }; };
  }
  wrapper.arity = 9;
  wrapper.func = fun;
  return wrapper;
}

function A2(fun, a, b)
{
  return fun.arity === 2
    ? fun.func(a, b)
    : fun(a)(b);
}
function A3(fun, a, b, c)
{
  return fun.arity === 3
    ? fun.func(a, b, c)
    : fun(a)(b)(c);
}
function A4(fun, a, b, c, d)
{
  return fun.arity === 4
    ? fun.func(a, b, c, d)
    : fun(a)(b)(c)(d);
}
function A5(fun, a, b, c, d, e)
{
  return fun.arity === 5
    ? fun.func(a, b, c, d, e)
    : fun(a)(b)(c)(d)(e);
}
function A6(fun, a, b, c, d, e, f)
{
  return fun.arity === 6
    ? fun.func(a, b, c, d, e, f)
    : fun(a)(b)(c)(d)(e)(f);
}
function A7(fun, a, b, c, d, e, f, g)
{
  return fun.arity === 7
    ? fun.func(a, b, c, d, e, f, g)
    : fun(a)(b)(c)(d)(e)(f)(g);
}
function A8(fun, a, b, c, d, e, f, g, h)
{
  return fun.arity === 8
    ? fun.func(a, b, c, d, e, f, g, h)
    : fun(a)(b)(c)(d)(e)(f)(g)(h);
}
function A9(fun, a, b, c, d, e, f, g, h, i)
{
  return fun.arity === 9
    ? fun.func(a, b, c, d, e, f, g, h, i)
    : fun(a)(b)(c)(d)(e)(f)(g)(h)(i);
}

//import Native.List //

var _elm_lang$core$Native_Array = function() {

// A RRB-Tree has two distinct data types.
// Leaf -> "height"  is always 0
//         "table"   is an array of elements
// Node -> "height"  is always greater than 0
//         "table"   is an array of child nodes
//         "lengths" is an array of accumulated lengths of the child nodes

// M is the maximal table size. 32 seems fast. E is the allowed increase
// of search steps when concatting to find an index. Lower values will
// decrease balancing, but will increase search steps.
var M = 32;
var E = 2;

// An empty array.
var empty = {
	ctor: '_Array',
	height: 0,
	table: []
};


function get(i, array)
{
	if (i < 0 || i >= length(array))
	{
		throw new Error(
			'Index ' + i + ' is out of range. Check the length of ' +
			'your array first or use getMaybe or getWithDefault.');
	}
	return unsafeGet(i, array);
}


function unsafeGet(i, array)
{
	for (var x = array.height; x > 0; x--)
	{
		var slot = i >> (x * 5);
		while (array.lengths[slot] <= i)
		{
			slot++;
		}
		if (slot > 0)
		{
			i -= array.lengths[slot - 1];
		}
		array = array.table[slot];
	}
	return array.table[i];
}


// Sets the value at the index i. Only the nodes leading to i will get
// copied and updated.
function set(i, item, array)
{
	if (i < 0 || length(array) <= i)
	{
		return array;
	}
	return unsafeSet(i, item, array);
}


function unsafeSet(i, item, array)
{
	array = nodeCopy(array);

	if (array.height === 0)
	{
		array.table[i] = item;
	}
	else
	{
		var slot = getSlot(i, array);
		if (slot > 0)
		{
			i -= array.lengths[slot - 1];
		}
		array.table[slot] = unsafeSet(i, item, array.table[slot]);
	}
	return array;
}


function initialize(len, f)
{
	if (len <= 0)
	{
		return empty;
	}
	var h = Math.floor( Math.log(len) / Math.log(M) );
	return initialize_(f, h, 0, len);
}

function initialize_(f, h, from, to)
{
	if (h === 0)
	{
		var table = new Array((to - from) % (M + 1));
		for (var i = 0; i < table.length; i++)
		{
		  table[i] = f(from + i);
		}
		return {
			ctor: '_Array',
			height: 0,
			table: table
		};
	}

	var step = Math.pow(M, h);
	var table = new Array(Math.ceil((to - from) / step));
	var lengths = new Array(table.length);
	for (var i = 0; i < table.length; i++)
	{
		table[i] = initialize_(f, h - 1, from + (i * step), Math.min(from + ((i + 1) * step), to));
		lengths[i] = length(table[i]) + (i > 0 ? lengths[i-1] : 0);
	}
	return {
		ctor: '_Array',
		height: h,
		table: table,
		lengths: lengths
	};
}

function fromList(list)
{
	if (list.ctor === '[]')
	{
		return empty;
	}

	// Allocate M sized blocks (table) and write list elements to it.
	var table = new Array(M);
	var nodes = [];
	var i = 0;

	while (list.ctor !== '[]')
	{
		table[i] = list._0;
		list = list._1;
		i++;

		// table is full, so we can push a leaf containing it into the
		// next node.
		if (i === M)
		{
			var leaf = {
				ctor: '_Array',
				height: 0,
				table: table
			};
			fromListPush(leaf, nodes);
			table = new Array(M);
			i = 0;
		}
	}

	// Maybe there is something left on the table.
	if (i > 0)
	{
		var leaf = {
			ctor: '_Array',
			height: 0,
			table: table.splice(0, i)
		};
		fromListPush(leaf, nodes);
	}

	// Go through all of the nodes and eventually push them into higher nodes.
	for (var h = 0; h < nodes.length - 1; h++)
	{
		if (nodes[h].table.length > 0)
		{
			fromListPush(nodes[h], nodes);
		}
	}

	var head = nodes[nodes.length - 1];
	if (head.height > 0 && head.table.length === 1)
	{
		return head.table[0];
	}
	else
	{
		return head;
	}
}

// Push a node into a higher node as a child.
function fromListPush(toPush, nodes)
{
	var h = toPush.height;

	// Maybe the node on this height does not exist.
	if (nodes.length === h)
	{
		var node = {
			ctor: '_Array',
			height: h + 1,
			table: [],
			lengths: []
		};
		nodes.push(node);
	}

	nodes[h].table.push(toPush);
	var len = length(toPush);
	if (nodes[h].lengths.length > 0)
	{
		len += nodes[h].lengths[nodes[h].lengths.length - 1];
	}
	nodes[h].lengths.push(len);

	if (nodes[h].table.length === M)
	{
		fromListPush(nodes[h], nodes);
		nodes[h] = {
			ctor: '_Array',
			height: h + 1,
			table: [],
			lengths: []
		};
	}
}

// Pushes an item via push_ to the bottom right of a tree.
function push(item, a)
{
	var pushed = push_(item, a);
	if (pushed !== null)
	{
		return pushed;
	}

	var newTree = create(item, a.height);
	return siblise(a, newTree);
}

// Recursively tries to push an item to the bottom-right most
// tree possible. If there is no space left for the item,
// null will be returned.
function push_(item, a)
{
	// Handle resursion stop at leaf level.
	if (a.height === 0)
	{
		if (a.table.length < M)
		{
			var newA = {
				ctor: '_Array',
				height: 0,
				table: a.table.slice()
			};
			newA.table.push(item);
			return newA;
		}
		else
		{
		  return null;
		}
	}

	// Recursively push
	var pushed = push_(item, botRight(a));

	// There was space in the bottom right tree, so the slot will
	// be updated.
	if (pushed !== null)
	{
		var newA = nodeCopy(a);
		newA.table[newA.table.length - 1] = pushed;
		newA.lengths[newA.lengths.length - 1]++;
		return newA;
	}

	// When there was no space left, check if there is space left
	// for a new slot with a tree which contains only the item
	// at the bottom.
	if (a.table.length < M)
	{
		var newSlot = create(item, a.height - 1);
		var newA = nodeCopy(a);
		newA.table.push(newSlot);
		newA.lengths.push(newA.lengths[newA.lengths.length - 1] + length(newSlot));
		return newA;
	}
	else
	{
		return null;
	}
}

// Converts an array into a list of elements.
function toList(a)
{
	return toList_(_elm_lang$core$Native_List.Nil, a);
}

function toList_(list, a)
{
	for (var i = a.table.length - 1; i >= 0; i--)
	{
		list =
			a.height === 0
				? _elm_lang$core$Native_List.Cons(a.table[i], list)
				: toList_(list, a.table[i]);
	}
	return list;
}

// Maps a function over the elements of an array.
function map(f, a)
{
	var newA = {
		ctor: '_Array',
		height: a.height,
		table: new Array(a.table.length)
	};
	if (a.height > 0)
	{
		newA.lengths = a.lengths;
	}
	for (var i = 0; i < a.table.length; i++)
	{
		newA.table[i] =
			a.height === 0
				? f(a.table[i])
				: map(f, a.table[i]);
	}
	return newA;
}

// Maps a function over the elements with their index as first argument.
function indexedMap(f, a)
{
	return indexedMap_(f, a, 0);
}

function indexedMap_(f, a, from)
{
	var newA = {
		ctor: '_Array',
		height: a.height,
		table: new Array(a.table.length)
	};
	if (a.height > 0)
	{
		newA.lengths = a.lengths;
	}
	for (var i = 0; i < a.table.length; i++)
	{
		newA.table[i] =
			a.height === 0
				? A2(f, from + i, a.table[i])
				: indexedMap_(f, a.table[i], i == 0 ? from : from + a.lengths[i - 1]);
	}
	return newA;
}

function foldl(f, b, a)
{
	if (a.height === 0)
	{
		for (var i = 0; i < a.table.length; i++)
		{
			b = A2(f, a.table[i], b);
		}
	}
	else
	{
		for (var i = 0; i < a.table.length; i++)
		{
			b = foldl(f, b, a.table[i]);
		}
	}
	return b;
}

function foldr(f, b, a)
{
	if (a.height === 0)
	{
		for (var i = a.table.length; i--; )
		{
			b = A2(f, a.table[i], b);
		}
	}
	else
	{
		for (var i = a.table.length; i--; )
		{
			b = foldr(f, b, a.table[i]);
		}
	}
	return b;
}

// TODO: currently, it slices the right, then the left. This can be
// optimized.
function slice(from, to, a)
{
	if (from < 0)
	{
		from += length(a);
	}
	if (to < 0)
	{
		to += length(a);
	}
	return sliceLeft(from, sliceRight(to, a));
}

function sliceRight(to, a)
{
	if (to === length(a))
	{
		return a;
	}

	// Handle leaf level.
	if (a.height === 0)
	{
		var newA = { ctor:'_Array', height:0 };
		newA.table = a.table.slice(0, to);
		return newA;
	}

	// Slice the right recursively.
	var right = getSlot(to, a);
	var sliced = sliceRight(to - (right > 0 ? a.lengths[right - 1] : 0), a.table[right]);

	// Maybe the a node is not even needed, as sliced contains the whole slice.
	if (right === 0)
	{
		return sliced;
	}

	// Create new node.
	var newA = {
		ctor: '_Array',
		height: a.height,
		table: a.table.slice(0, right),
		lengths: a.lengths.slice(0, right)
	};
	if (sliced.table.length > 0)
	{
		newA.table[right] = sliced;
		newA.lengths[right] = length(sliced) + (right > 0 ? newA.lengths[right - 1] : 0);
	}
	return newA;
}

function sliceLeft(from, a)
{
	if (from === 0)
	{
		return a;
	}

	// Handle leaf level.
	if (a.height === 0)
	{
		var newA = { ctor:'_Array', height:0 };
		newA.table = a.table.slice(from, a.table.length + 1);
		return newA;
	}

	// Slice the left recursively.
	var left = getSlot(from, a);
	var sliced = sliceLeft(from - (left > 0 ? a.lengths[left - 1] : 0), a.table[left]);

	// Maybe the a node is not even needed, as sliced contains the whole slice.
	if (left === a.table.length - 1)
	{
		return sliced;
	}

	// Create new node.
	var newA = {
		ctor: '_Array',
		height: a.height,
		table: a.table.slice(left, a.table.length + 1),
		lengths: new Array(a.table.length - left)
	};
	newA.table[0] = sliced;
	var len = 0;
	for (var i = 0; i < newA.table.length; i++)
	{
		len += length(newA.table[i]);
		newA.lengths[i] = len;
	}

	return newA;
}

// Appends two trees.
function append(a,b)
{
	if (a.table.length === 0)
	{
		return b;
	}
	if (b.table.length === 0)
	{
		return a;
	}

	var c = append_(a, b);

	// Check if both nodes can be crunshed together.
	if (c[0].table.length + c[1].table.length <= M)
	{
		if (c[0].table.length === 0)
		{
			return c[1];
		}
		if (c[1].table.length === 0)
		{
			return c[0];
		}

		// Adjust .table and .lengths
		c[0].table = c[0].table.concat(c[1].table);
		if (c[0].height > 0)
		{
			var len = length(c[0]);
			for (var i = 0; i < c[1].lengths.length; i++)
			{
				c[1].lengths[i] += len;
			}
			c[0].lengths = c[0].lengths.concat(c[1].lengths);
		}

		return c[0];
	}

	if (c[0].height > 0)
	{
		var toRemove = calcToRemove(a, b);
		if (toRemove > E)
		{
			c = shuffle(c[0], c[1], toRemove);
		}
	}

	return siblise(c[0], c[1]);
}

// Returns an array of two nodes; right and left. One node _may_ be empty.
function append_(a, b)
{
	if (a.height === 0 && b.height === 0)
	{
		return [a, b];
	}

	if (a.height !== 1 || b.height !== 1)
	{
		if (a.height === b.height)
		{
			a = nodeCopy(a);
			b = nodeCopy(b);
			var appended = append_(botRight(a), botLeft(b));

			insertRight(a, appended[1]);
			insertLeft(b, appended[0]);
		}
		else if (a.height > b.height)
		{
			a = nodeCopy(a);
			var appended = append_(botRight(a), b);

			insertRight(a, appended[0]);
			b = parentise(appended[1], appended[1].height + 1);
		}
		else
		{
			b = nodeCopy(b);
			var appended = append_(a, botLeft(b));

			var left = appended[0].table.length === 0 ? 0 : 1;
			var right = left === 0 ? 1 : 0;
			insertLeft(b, appended[left]);
			a = parentise(appended[right], appended[right].height + 1);
		}
	}

	// Check if balancing is needed and return based on that.
	if (a.table.length === 0 || b.table.length === 0)
	{
		return [a, b];
	}

	var toRemove = calcToRemove(a, b);
	if (toRemove <= E)
	{
		return [a, b];
	}
	return shuffle(a, b, toRemove);
}

// Helperfunctions for append_. Replaces a child node at the side of the parent.
function insertRight(parent, node)
{
	var index = parent.table.length - 1;
	parent.table[index] = node;
	parent.lengths[index] = length(node);
	parent.lengths[index] += index > 0 ? parent.lengths[index - 1] : 0;
}

function insertLeft(parent, node)
{
	if (node.table.length > 0)
	{
		parent.table[0] = node;
		parent.lengths[0] = length(node);

		var len = length(parent.table[0]);
		for (var i = 1; i < parent.lengths.length; i++)
		{
			len += length(parent.table[i]);
			parent.lengths[i] = len;
		}
	}
	else
	{
		parent.table.shift();
		for (var i = 1; i < parent.lengths.length; i++)
		{
			parent.lengths[i] = parent.lengths[i] - parent.lengths[0];
		}
		parent.lengths.shift();
	}
}

// Returns the extra search steps for E. Refer to the paper.
function calcToRemove(a, b)
{
	var subLengths = 0;
	for (var i = 0; i < a.table.length; i++)
	{
		subLengths += a.table[i].table.length;
	}
	for (var i = 0; i < b.table.length; i++)
	{
		subLengths += b.table[i].table.length;
	}

	var toRemove = a.table.length + b.table.length;
	return toRemove - (Math.floor((subLengths - 1) / M) + 1);
}

// get2, set2 and saveSlot are helpers for accessing elements over two arrays.
function get2(a, b, index)
{
	return index < a.length
		? a[index]
		: b[index - a.length];
}

function set2(a, b, index, value)
{
	if (index < a.length)
	{
		a[index] = value;
	}
	else
	{
		b[index - a.length] = value;
	}
}

function saveSlot(a, b, index, slot)
{
	set2(a.table, b.table, index, slot);

	var l = (index === 0 || index === a.lengths.length)
		? 0
		: get2(a.lengths, a.lengths, index - 1);

	set2(a.lengths, b.lengths, index, l + length(slot));
}

// Creates a node or leaf with a given length at their arrays for perfomance.
// Is only used by shuffle.
function createNode(h, length)
{
	if (length < 0)
	{
		length = 0;
	}
	var a = {
		ctor: '_Array',
		height: h,
		table: new Array(length)
	};
	if (h > 0)
	{
		a.lengths = new Array(length);
	}
	return a;
}

// Returns an array of two balanced nodes.
function shuffle(a, b, toRemove)
{
	var newA = createNode(a.height, Math.min(M, a.table.length + b.table.length - toRemove));
	var newB = createNode(a.height, newA.table.length - (a.table.length + b.table.length - toRemove));

	// Skip the slots with size M. More precise: copy the slot references
	// to the new node
	var read = 0;
	while (get2(a.table, b.table, read).table.length % M === 0)
	{
		set2(newA.table, newB.table, read, get2(a.table, b.table, read));
		set2(newA.lengths, newB.lengths, read, get2(a.lengths, b.lengths, read));
		read++;
	}

	// Pulling items from left to right, caching in a slot before writing
	// it into the new nodes.
	var write = read;
	var slot = new createNode(a.height - 1, 0);
	var from = 0;

	// If the current slot is still containing data, then there will be at
	// least one more write, so we do not break this loop yet.
	while (read - write - (slot.table.length > 0 ? 1 : 0) < toRemove)
	{
		// Find out the max possible items for copying.
		var source = get2(a.table, b.table, read);
		var to = Math.min(M - slot.table.length, source.table.length);

		// Copy and adjust size table.
		slot.table = slot.table.concat(source.table.slice(from, to));
		if (slot.height > 0)
		{
			var len = slot.lengths.length;
			for (var i = len; i < len + to - from; i++)
			{
				slot.lengths[i] = length(slot.table[i]);
				slot.lengths[i] += (i > 0 ? slot.lengths[i - 1] : 0);
			}
		}

		from += to;

		// Only proceed to next slots[i] if the current one was
		// fully copied.
		if (source.table.length <= to)
		{
			read++; from = 0;
		}

		// Only create a new slot if the current one is filled up.
		if (slot.table.length === M)
		{
			saveSlot(newA, newB, write, slot);
			slot = createNode(a.height - 1, 0);
			write++;
		}
	}

	// Cleanup after the loop. Copy the last slot into the new nodes.
	if (slot.table.length > 0)
	{
		saveSlot(newA, newB, write, slot);
		write++;
	}

	// Shift the untouched slots to the left
	while (read < a.table.length + b.table.length )
	{
		saveSlot(newA, newB, write, get2(a.table, b.table, read));
		read++;
		write++;
	}

	return [newA, newB];
}

// Navigation functions
function botRight(a)
{
	return a.table[a.table.length - 1];
}
function botLeft(a)
{
	return a.table[0];
}

// Copies a node for updating. Note that you should not use this if
// only updating only one of "table" or "lengths" for performance reasons.
function nodeCopy(a)
{
	var newA = {
		ctor: '_Array',
		height: a.height,
		table: a.table.slice()
	};
	if (a.height > 0)
	{
		newA.lengths = a.lengths.slice();
	}
	return newA;
}

// Returns how many items are in the tree.
function length(array)
{
	if (array.height === 0)
	{
		return array.table.length;
	}
	else
	{
		return array.lengths[array.lengths.length - 1];
	}
}

// Calculates in which slot of "table" the item probably is, then
// find the exact slot via forward searching in  "lengths". Returns the index.
function getSlot(i, a)
{
	var slot = i >> (5 * a.height);
	while (a.lengths[slot] <= i)
	{
		slot++;
	}
	return slot;
}

// Recursively creates a tree with a given height containing
// only the given item.
function create(item, h)
{
	if (h === 0)
	{
		return {
			ctor: '_Array',
			height: 0,
			table: [item]
		};
	}
	return {
		ctor: '_Array',
		height: h,
		table: [create(item, h - 1)],
		lengths: [1]
	};
}

// Recursively creates a tree that contains the given tree.
function parentise(tree, h)
{
	if (h === tree.height)
	{
		return tree;
	}

	return {
		ctor: '_Array',
		height: h,
		table: [parentise(tree, h - 1)],
		lengths: [length(tree)]
	};
}

// Emphasizes blood brotherhood beneath two trees.
function siblise(a, b)
{
	return {
		ctor: '_Array',
		height: a.height + 1,
		table: [a, b],
		lengths: [length(a), length(a) + length(b)]
	};
}

function toJSArray(a)
{
	var jsArray = new Array(length(a));
	toJSArray_(jsArray, 0, a);
	return jsArray;
}

function toJSArray_(jsArray, i, a)
{
	for (var t = 0; t < a.table.length; t++)
	{
		if (a.height === 0)
		{
			jsArray[i + t] = a.table[t];
		}
		else
		{
			var inc = t === 0 ? 0 : a.lengths[t - 1];
			toJSArray_(jsArray, i + inc, a.table[t]);
		}
	}
}

function fromJSArray(jsArray)
{
	if (jsArray.length === 0)
	{
		return empty;
	}
	var h = Math.floor(Math.log(jsArray.length) / Math.log(M));
	return fromJSArray_(jsArray, h, 0, jsArray.length);
}

function fromJSArray_(jsArray, h, from, to)
{
	if (h === 0)
	{
		return {
			ctor: '_Array',
			height: 0,
			table: jsArray.slice(from, to)
		};
	}

	var step = Math.pow(M, h);
	var table = new Array(Math.ceil((to - from) / step));
	var lengths = new Array(table.length);
	for (var i = 0; i < table.length; i++)
	{
		table[i] = fromJSArray_(jsArray, h - 1, from + (i * step), Math.min(from + ((i + 1) * step), to));
		lengths[i] = length(table[i]) + (i > 0 ? lengths[i - 1] : 0);
	}
	return {
		ctor: '_Array',
		height: h,
		table: table,
		lengths: lengths
	};
}

return {
	empty: empty,
	fromList: fromList,
	toList: toList,
	initialize: F2(initialize),
	append: F2(append),
	push: F2(push),
	slice: F3(slice),
	get: F2(get),
	set: F3(set),
	map: F2(map),
	indexedMap: F2(indexedMap),
	foldl: F3(foldl),
	foldr: F3(foldr),
	length: length,

	toJSArray: toJSArray,
	fromJSArray: fromJSArray
};

}();
//import Native.Utils //

var _elm_lang$core$Native_Basics = function() {

function div(a, b)
{
	return (a / b) | 0;
}
function rem(a, b)
{
	return a % b;
}
function mod(a, b)
{
	if (b === 0)
	{
		throw new Error('Cannot perform mod 0. Division by zero error.');
	}
	var r = a % b;
	var m = a === 0 ? 0 : (b > 0 ? (a >= 0 ? r : r + b) : -mod(-a, -b));

	return m === b ? 0 : m;
}
function logBase(base, n)
{
	return Math.log(n) / Math.log(base);
}
function negate(n)
{
	return -n;
}
function abs(n)
{
	return n < 0 ? -n : n;
}

function min(a, b)
{
	return _elm_lang$core$Native_Utils.cmp(a, b) < 0 ? a : b;
}
function max(a, b)
{
	return _elm_lang$core$Native_Utils.cmp(a, b) > 0 ? a : b;
}
function clamp(lo, hi, n)
{
	return _elm_lang$core$Native_Utils.cmp(n, lo) < 0
		? lo
		: _elm_lang$core$Native_Utils.cmp(n, hi) > 0
			? hi
			: n;
}

var ord = ['LT', 'EQ', 'GT'];

function compare(x, y)
{
	return { ctor: ord[_elm_lang$core$Native_Utils.cmp(x, y) + 1] };
}

function xor(a, b)
{
	return a !== b;
}
function not(b)
{
	return !b;
}
function isInfinite(n)
{
	return n === Infinity || n === -Infinity;
}

function truncate(n)
{
	return n | 0;
}

function degrees(d)
{
	return d * Math.PI / 180;
}
function turns(t)
{
	return 2 * Math.PI * t;
}
function fromPolar(point)
{
	var r = point._0;
	var t = point._1;
	return _elm_lang$core$Native_Utils.Tuple2(r * Math.cos(t), r * Math.sin(t));
}
function toPolar(point)
{
	var x = point._0;
	var y = point._1;
	return _elm_lang$core$Native_Utils.Tuple2(Math.sqrt(x * x + y * y), Math.atan2(y, x));
}

return {
	div: F2(div),
	rem: F2(rem),
	mod: F2(mod),

	pi: Math.PI,
	e: Math.E,
	cos: Math.cos,
	sin: Math.sin,
	tan: Math.tan,
	acos: Math.acos,
	asin: Math.asin,
	atan: Math.atan,
	atan2: F2(Math.atan2),

	degrees: degrees,
	turns: turns,
	fromPolar: fromPolar,
	toPolar: toPolar,

	sqrt: Math.sqrt,
	logBase: F2(logBase),
	negate: negate,
	abs: abs,
	min: F2(min),
	max: F2(max),
	clamp: F3(clamp),
	compare: F2(compare),

	xor: F2(xor),
	not: not,

	truncate: truncate,
	ceiling: Math.ceil,
	floor: Math.floor,
	round: Math.round,
	toFloat: function(x) { return x; },
	isNaN: isNaN,
	isInfinite: isInfinite
};

}();
//import //

var _elm_lang$core$Native_Utils = function() {

// COMPARISONS

function eq(x, y)
{
	var stack = [];
	var isEqual = eqHelp(x, y, 0, stack);
	var pair;
	while (isEqual && (pair = stack.pop()))
	{
		isEqual = eqHelp(pair.x, pair.y, 0, stack);
	}
	return isEqual;
}


function eqHelp(x, y, depth, stack)
{
	if (depth > 100)
	{
		stack.push({ x: x, y: y });
		return true;
	}

	if (x === y)
	{
		return true;
	}

	if (typeof x !== 'object')
	{
		if (typeof x === 'function')
		{
			throw new Error(
				'Trying to use `(==)` on functions. There is no way to know if functions are "the same" in the Elm sense.'
				+ ' Read more about this at http://package.elm-lang.org/packages/elm-lang/core/latest/Basics#=='
				+ ' which describes why it is this way and what the better version will look like.'
			);
		}
		return false;
	}

	if (x === null || y === null)
	{
		return false
	}

	if (x instanceof Date)
	{
		return x.getTime() === y.getTime();
	}

	if (!('ctor' in x))
	{
		for (var key in x)
		{
			if (!eqHelp(x[key], y[key], depth + 1, stack))
			{
				return false;
			}
		}
		return true;
	}

	// convert Dicts and Sets to lists
	if (x.ctor === 'RBNode_elm_builtin' || x.ctor === 'RBEmpty_elm_builtin')
	{
		x = _elm_lang$core$Dict$toList(x);
		y = _elm_lang$core$Dict$toList(y);
	}
	if (x.ctor === 'Set_elm_builtin')
	{
		x = _elm_lang$core$Set$toList(x);
		y = _elm_lang$core$Set$toList(y);
	}

	// check if lists are equal without recursion
	if (x.ctor === '::')
	{
		var a = x;
		var b = y;
		while (a.ctor === '::' && b.ctor === '::')
		{
			if (!eqHelp(a._0, b._0, depth + 1, stack))
			{
				return false;
			}
			a = a._1;
			b = b._1;
		}
		return a.ctor === b.ctor;
	}

	// check if Arrays are equal
	if (x.ctor === '_Array')
	{
		var xs = _elm_lang$core$Native_Array.toJSArray(x);
		var ys = _elm_lang$core$Native_Array.toJSArray(y);
		if (xs.length !== ys.length)
		{
			return false;
		}
		for (var i = 0; i < xs.length; i++)
		{
			if (!eqHelp(xs[i], ys[i], depth + 1, stack))
			{
				return false;
			}
		}
		return true;
	}

	if (!eqHelp(x.ctor, y.ctor, depth + 1, stack))
	{
		return false;
	}

	for (var key in x)
	{
		if (!eqHelp(x[key], y[key], depth + 1, stack))
		{
			return false;
		}
	}
	return true;
}

// Code in Generate/JavaScript.hs, Basics.js, and List.js depends on
// the particular integer values assigned to LT, EQ, and GT.

var LT = -1, EQ = 0, GT = 1;

function cmp(x, y)
{
	if (typeof x !== 'object')
	{
		return x === y ? EQ : x < y ? LT : GT;
	}

	if (x instanceof String)
	{
		var a = x.valueOf();
		var b = y.valueOf();
		return a === b ? EQ : a < b ? LT : GT;
	}

	if (x.ctor === '::' || x.ctor === '[]')
	{
		while (x.ctor === '::' && y.ctor === '::')
		{
			var ord = cmp(x._0, y._0);
			if (ord !== EQ)
			{
				return ord;
			}
			x = x._1;
			y = y._1;
		}
		return x.ctor === y.ctor ? EQ : x.ctor === '[]' ? LT : GT;
	}

	if (x.ctor.slice(0, 6) === '_Tuple')
	{
		var ord;
		var n = x.ctor.slice(6) - 0;
		var err = 'cannot compare tuples with more than 6 elements.';
		if (n === 0) return EQ;
		if (n >= 1) { ord = cmp(x._0, y._0); if (ord !== EQ) return ord;
		if (n >= 2) { ord = cmp(x._1, y._1); if (ord !== EQ) return ord;
		if (n >= 3) { ord = cmp(x._2, y._2); if (ord !== EQ) return ord;
		if (n >= 4) { ord = cmp(x._3, y._3); if (ord !== EQ) return ord;
		if (n >= 5) { ord = cmp(x._4, y._4); if (ord !== EQ) return ord;
		if (n >= 6) { ord = cmp(x._5, y._5); if (ord !== EQ) return ord;
		if (n >= 7) throw new Error('Comparison error: ' + err); } } } } } }
		return EQ;
	}

	throw new Error(
		'Comparison error: comparison is only defined on ints, '
		+ 'floats, times, chars, strings, lists of comparable values, '
		+ 'and tuples of comparable values.'
	);
}


// COMMON VALUES

var Tuple0 = {
	ctor: '_Tuple0'
};

function Tuple2(x, y)
{
	return {
		ctor: '_Tuple2',
		_0: x,
		_1: y
	};
}

function chr(c)
{
	return new String(c);
}


// GUID

var count = 0;
function guid(_)
{
	return count++;
}


// RECORDS

function update(oldRecord, updatedFields)
{
	var newRecord = {};

	for (var key in oldRecord)
	{
		newRecord[key] = oldRecord[key];
	}

	for (var key in updatedFields)
	{
		newRecord[key] = updatedFields[key];
	}

	return newRecord;
}


//// LIST STUFF ////

var Nil = { ctor: '[]' };

function Cons(hd, tl)
{
	return {
		ctor: '::',
		_0: hd,
		_1: tl
	};
}

function append(xs, ys)
{
	// append Strings
	if (typeof xs === 'string')
	{
		return xs + ys;
	}

	// append Lists
	if (xs.ctor === '[]')
	{
		return ys;
	}
	var root = Cons(xs._0, Nil);
	var curr = root;
	xs = xs._1;
	while (xs.ctor !== '[]')
	{
		curr._1 = Cons(xs._0, Nil);
		xs = xs._1;
		curr = curr._1;
	}
	curr._1 = ys;
	return root;
}


// CRASHES

function crash(moduleName, region)
{
	return function(message) {
		throw new Error(
			'Ran into a `Debug.crash` in module `' + moduleName + '` ' + regionToString(region) + '\n'
			+ 'The message provided by the code author is:\n\n    '
			+ message
		);
	};
}

function crashCase(moduleName, region, value)
{
	return function(message) {
		throw new Error(
			'Ran into a `Debug.crash` in module `' + moduleName + '`\n\n'
			+ 'This was caused by the `case` expression ' + regionToString(region) + '.\n'
			+ 'One of the branches ended with a crash and the following value got through:\n\n    ' + toString(value) + '\n\n'
			+ 'The message provided by the code author is:\n\n    '
			+ message
		);
	};
}

function regionToString(region)
{
	if (region.start.line == region.end.line)
	{
		return 'on line ' + region.start.line;
	}
	return 'between lines ' + region.start.line + ' and ' + region.end.line;
}


// TO STRING

function toString(v)
{
	var type = typeof v;
	if (type === 'function')
	{
		var name = v.func ? v.func.name : v.name;
		return '<function' + (name === '' ? '' : ':') + name + '>';
	}

	if (type === 'boolean')
	{
		return v ? 'True' : 'False';
	}

	if (type === 'number')
	{
		return v + '';
	}

	if (v instanceof String)
	{
		return '\'' + addSlashes(v, true) + '\'';
	}

	if (type === 'string')
	{
		return '"' + addSlashes(v, false) + '"';
	}

	if (v === null)
	{
		return 'null';
	}

	if (type === 'object' && 'ctor' in v)
	{
		var ctorStarter = v.ctor.substring(0, 5);

		if (ctorStarter === '_Tupl')
		{
			var output = [];
			for (var k in v)
			{
				if (k === 'ctor') continue;
				output.push(toString(v[k]));
			}
			return '(' + output.join(',') + ')';
		}

		if (ctorStarter === '_Task')
		{
			return '<task>'
		}

		if (v.ctor === '_Array')
		{
			var list = _elm_lang$core$Array$toList(v);
			return 'Array.fromList ' + toString(list);
		}

		if (v.ctor === '<decoder>')
		{
			return '<decoder>';
		}

		if (v.ctor === '_Process')
		{
			return '<process:' + v.id + '>';
		}

		if (v.ctor === '::')
		{
			var output = '[' + toString(v._0);
			v = v._1;
			while (v.ctor === '::')
			{
				output += ',' + toString(v._0);
				v = v._1;
			}
			return output + ']';
		}

		if (v.ctor === '[]')
		{
			return '[]';
		}

		if (v.ctor === 'Set_elm_builtin')
		{
			return 'Set.fromList ' + toString(_elm_lang$core$Set$toList(v));
		}

		if (v.ctor === 'RBNode_elm_builtin' || v.ctor === 'RBEmpty_elm_builtin')
		{
			return 'Dict.fromList ' + toString(_elm_lang$core$Dict$toList(v));
		}

		var output = '';
		for (var i in v)
		{
			if (i === 'ctor') continue;
			var str = toString(v[i]);
			var c0 = str[0];
			var parenless = c0 === '{' || c0 === '(' || c0 === '<' || c0 === '"' || str.indexOf(' ') < 0;
			output += ' ' + (parenless ? str : '(' + str + ')');
		}
		return v.ctor + output;
	}

	if (type === 'object')
	{
		if (v instanceof Date)
		{
			return '<' + v.toString() + '>';
		}

		if (v.elm_web_socket)
		{
			return '<websocket>';
		}

		var output = [];
		for (var k in v)
		{
			output.push(k + ' = ' + toString(v[k]));
		}
		if (output.length === 0)
		{
			return '{}';
		}
		return '{ ' + output.join(', ') + ' }';
	}

	return '<internal structure>';
}

function addSlashes(str, isChar)
{
	var s = str.replace(/\\/g, '\\\\')
			  .replace(/\n/g, '\\n')
			  .replace(/\t/g, '\\t')
			  .replace(/\r/g, '\\r')
			  .replace(/\v/g, '\\v')
			  .replace(/\0/g, '\\0');
	if (isChar)
	{
		return s.replace(/\'/g, '\\\'');
	}
	else
	{
		return s.replace(/\"/g, '\\"');
	}
}


return {
	eq: eq,
	cmp: cmp,
	Tuple0: Tuple0,
	Tuple2: Tuple2,
	chr: chr,
	update: update,
	guid: guid,

	append: F2(append),

	crash: crash,
	crashCase: crashCase,

	toString: toString
};

}();
var _elm_lang$core$Basics$never = function (_p0) {
	never:
	while (true) {
		var _p1 = _p0;
		var _v1 = _p1._0;
		_p0 = _v1;
		continue never;
	}
};
var _elm_lang$core$Basics$uncurry = F2(
	function (f, _p2) {
		var _p3 = _p2;
		return A2(f, _p3._0, _p3._1);
	});
var _elm_lang$core$Basics$curry = F3(
	function (f, a, b) {
		return f(
			{ctor: '_Tuple2', _0: a, _1: b});
	});
var _elm_lang$core$Basics$flip = F3(
	function (f, b, a) {
		return A2(f, a, b);
	});
var _elm_lang$core$Basics$always = F2(
	function (a, _p4) {
		return a;
	});
var _elm_lang$core$Basics$identity = function (x) {
	return x;
};
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['<|'] = F2(
	function (f, x) {
		return f(x);
	});
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['|>'] = F2(
	function (x, f) {
		return f(x);
	});
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['>>'] = F3(
	function (f, g, x) {
		return g(
			f(x));
	});
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['<<'] = F3(
	function (g, f, x) {
		return g(
			f(x));
	});
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['++'] = _elm_lang$core$Native_Utils.append;
var _elm_lang$core$Basics$toString = _elm_lang$core$Native_Utils.toString;
var _elm_lang$core$Basics$isInfinite = _elm_lang$core$Native_Basics.isInfinite;
var _elm_lang$core$Basics$isNaN = _elm_lang$core$Native_Basics.isNaN;
var _elm_lang$core$Basics$toFloat = _elm_lang$core$Native_Basics.toFloat;
var _elm_lang$core$Basics$ceiling = _elm_lang$core$Native_Basics.ceiling;
var _elm_lang$core$Basics$floor = _elm_lang$core$Native_Basics.floor;
var _elm_lang$core$Basics$truncate = _elm_lang$core$Native_Basics.truncate;
var _elm_lang$core$Basics$round = _elm_lang$core$Native_Basics.round;
var _elm_lang$core$Basics$not = _elm_lang$core$Native_Basics.not;
var _elm_lang$core$Basics$xor = _elm_lang$core$Native_Basics.xor;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['||'] = _elm_lang$core$Native_Basics.or;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['&&'] = _elm_lang$core$Native_Basics.and;
var _elm_lang$core$Basics$max = _elm_lang$core$Native_Basics.max;
var _elm_lang$core$Basics$min = _elm_lang$core$Native_Basics.min;
var _elm_lang$core$Basics$compare = _elm_lang$core$Native_Basics.compare;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['>='] = _elm_lang$core$Native_Basics.ge;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['<='] = _elm_lang$core$Native_Basics.le;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['>'] = _elm_lang$core$Native_Basics.gt;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['<'] = _elm_lang$core$Native_Basics.lt;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['/='] = _elm_lang$core$Native_Basics.neq;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['=='] = _elm_lang$core$Native_Basics.eq;
var _elm_lang$core$Basics$e = _elm_lang$core$Native_Basics.e;
var _elm_lang$core$Basics$pi = _elm_lang$core$Native_Basics.pi;
var _elm_lang$core$Basics$clamp = _elm_lang$core$Native_Basics.clamp;
var _elm_lang$core$Basics$logBase = _elm_lang$core$Native_Basics.logBase;
var _elm_lang$core$Basics$abs = _elm_lang$core$Native_Basics.abs;
var _elm_lang$core$Basics$negate = _elm_lang$core$Native_Basics.negate;
var _elm_lang$core$Basics$sqrt = _elm_lang$core$Native_Basics.sqrt;
var _elm_lang$core$Basics$atan2 = _elm_lang$core$Native_Basics.atan2;
var _elm_lang$core$Basics$atan = _elm_lang$core$Native_Basics.atan;
var _elm_lang$core$Basics$asin = _elm_lang$core$Native_Basics.asin;
var _elm_lang$core$Basics$acos = _elm_lang$core$Native_Basics.acos;
var _elm_lang$core$Basics$tan = _elm_lang$core$Native_Basics.tan;
var _elm_lang$core$Basics$sin = _elm_lang$core$Native_Basics.sin;
var _elm_lang$core$Basics$cos = _elm_lang$core$Native_Basics.cos;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['^'] = _elm_lang$core$Native_Basics.exp;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['%'] = _elm_lang$core$Native_Basics.mod;
var _elm_lang$core$Basics$rem = _elm_lang$core$Native_Basics.rem;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['//'] = _elm_lang$core$Native_Basics.div;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['/'] = _elm_lang$core$Native_Basics.floatDiv;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['*'] = _elm_lang$core$Native_Basics.mul;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['-'] = _elm_lang$core$Native_Basics.sub;
var _elm_lang$core$Basics_ops = _elm_lang$core$Basics_ops || {};
_elm_lang$core$Basics_ops['+'] = _elm_lang$core$Native_Basics.add;
var _elm_lang$core$Basics$toPolar = _elm_lang$core$Native_Basics.toPolar;
var _elm_lang$core$Basics$fromPolar = _elm_lang$core$Native_Basics.fromPolar;
var _elm_lang$core$Basics$turns = _elm_lang$core$Native_Basics.turns;
var _elm_lang$core$Basics$degrees = _elm_lang$core$Native_Basics.degrees;
var _elm_lang$core$Basics$radians = function (t) {
	return t;
};
var _elm_lang$core$Basics$GT = {ctor: 'GT'};
var _elm_lang$core$Basics$EQ = {ctor: 'EQ'};
var _elm_lang$core$Basics$LT = {ctor: 'LT'};
var _elm_lang$core$Basics$JustOneMore = function (a) {
	return {ctor: 'JustOneMore', _0: a};
};

var _elm_lang$core$Maybe$withDefault = F2(
	function ($default, maybe) {
		var _p0 = maybe;
		if (_p0.ctor === 'Just') {
			return _p0._0;
		} else {
			return $default;
		}
	});
var _elm_lang$core$Maybe$Nothing = {ctor: 'Nothing'};
var _elm_lang$core$Maybe$andThen = F2(
	function (callback, maybeValue) {
		var _p1 = maybeValue;
		if (_p1.ctor === 'Just') {
			return callback(_p1._0);
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$Just = function (a) {
	return {ctor: 'Just', _0: a};
};
var _elm_lang$core$Maybe$map = F2(
	function (f, maybe) {
		var _p2 = maybe;
		if (_p2.ctor === 'Just') {
			return _elm_lang$core$Maybe$Just(
				f(_p2._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$map2 = F3(
	function (func, ma, mb) {
		var _p3 = {ctor: '_Tuple2', _0: ma, _1: mb};
		if (((_p3.ctor === '_Tuple2') && (_p3._0.ctor === 'Just')) && (_p3._1.ctor === 'Just')) {
			return _elm_lang$core$Maybe$Just(
				A2(func, _p3._0._0, _p3._1._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$map3 = F4(
	function (func, ma, mb, mc) {
		var _p4 = {ctor: '_Tuple3', _0: ma, _1: mb, _2: mc};
		if ((((_p4.ctor === '_Tuple3') && (_p4._0.ctor === 'Just')) && (_p4._1.ctor === 'Just')) && (_p4._2.ctor === 'Just')) {
			return _elm_lang$core$Maybe$Just(
				A3(func, _p4._0._0, _p4._1._0, _p4._2._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$map4 = F5(
	function (func, ma, mb, mc, md) {
		var _p5 = {ctor: '_Tuple4', _0: ma, _1: mb, _2: mc, _3: md};
		if (((((_p5.ctor === '_Tuple4') && (_p5._0.ctor === 'Just')) && (_p5._1.ctor === 'Just')) && (_p5._2.ctor === 'Just')) && (_p5._3.ctor === 'Just')) {
			return _elm_lang$core$Maybe$Just(
				A4(func, _p5._0._0, _p5._1._0, _p5._2._0, _p5._3._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});
var _elm_lang$core$Maybe$map5 = F6(
	function (func, ma, mb, mc, md, me) {
		var _p6 = {ctor: '_Tuple5', _0: ma, _1: mb, _2: mc, _3: md, _4: me};
		if ((((((_p6.ctor === '_Tuple5') && (_p6._0.ctor === 'Just')) && (_p6._1.ctor === 'Just')) && (_p6._2.ctor === 'Just')) && (_p6._3.ctor === 'Just')) && (_p6._4.ctor === 'Just')) {
			return _elm_lang$core$Maybe$Just(
				A5(func, _p6._0._0, _p6._1._0, _p6._2._0, _p6._3._0, _p6._4._0));
		} else {
			return _elm_lang$core$Maybe$Nothing;
		}
	});

//import Native.Utils //

var _elm_lang$core$Native_List = function() {

var Nil = { ctor: '[]' };

function Cons(hd, tl)
{
	return { ctor: '::', _0: hd, _1: tl };
}

function fromArray(arr)
{
	var out = Nil;
	for (var i = arr.length; i--; )
	{
		out = Cons(arr[i], out);
	}
	return out;
}

function toArray(xs)
{
	var out = [];
	while (xs.ctor !== '[]')
	{
		out.push(xs._0);
		xs = xs._1;
	}
	return out;
}

function foldr(f, b, xs)
{
	var arr = toArray(xs);
	var acc = b;
	for (var i = arr.length; i--; )
	{
		acc = A2(f, arr[i], acc);
	}
	return acc;
}

function map2(f, xs, ys)
{
	var arr = [];
	while (xs.ctor !== '[]' && ys.ctor !== '[]')
	{
		arr.push(A2(f, xs._0, ys._0));
		xs = xs._1;
		ys = ys._1;
	}
	return fromArray(arr);
}

function map3(f, xs, ys, zs)
{
	var arr = [];
	while (xs.ctor !== '[]' && ys.ctor !== '[]' && zs.ctor !== '[]')
	{
		arr.push(A3(f, xs._0, ys._0, zs._0));
		xs = xs._1;
		ys = ys._1;
		zs = zs._1;
	}
	return fromArray(arr);
}

function map4(f, ws, xs, ys, zs)
{
	var arr = [];
	while (   ws.ctor !== '[]'
		   && xs.ctor !== '[]'
		   && ys.ctor !== '[]'
		   && zs.ctor !== '[]')
	{
		arr.push(A4(f, ws._0, xs._0, ys._0, zs._0));
		ws = ws._1;
		xs = xs._1;
		ys = ys._1;
		zs = zs._1;
	}
	return fromArray(arr);
}

function map5(f, vs, ws, xs, ys, zs)
{
	var arr = [];
	while (   vs.ctor !== '[]'
		   && ws.ctor !== '[]'
		   && xs.ctor !== '[]'
		   && ys.ctor !== '[]'
		   && zs.ctor !== '[]')
	{
		arr.push(A5(f, vs._0, ws._0, xs._0, ys._0, zs._0));
		vs = vs._1;
		ws = ws._1;
		xs = xs._1;
		ys = ys._1;
		zs = zs._1;
	}
	return fromArray(arr);
}

function sortBy(f, xs)
{
	return fromArray(toArray(xs).sort(function(a, b) {
		return _elm_lang$core$Native_Utils.cmp(f(a), f(b));
	}));
}

function sortWith(f, xs)
{
	return fromArray(toArray(xs).sort(function(a, b) {
		var ord = f(a)(b).ctor;
		return ord === 'EQ' ? 0 : ord === 'LT' ? -1 : 1;
	}));
}

return {
	Nil: Nil,
	Cons: Cons,
	cons: F2(Cons),
	toArray: toArray,
	fromArray: fromArray,

	foldr: F3(foldr),

	map2: F3(map2),
	map3: F4(map3),
	map4: F5(map4),
	map5: F6(map5),
	sortBy: F2(sortBy),
	sortWith: F2(sortWith)
};

}();
var _elm_lang$core$List$sortWith = _elm_lang$core$Native_List.sortWith;
var _elm_lang$core$List$sortBy = _elm_lang$core$Native_List.sortBy;
var _elm_lang$core$List$sort = function (xs) {
	return A2(_elm_lang$core$List$sortBy, _elm_lang$core$Basics$identity, xs);
};
var _elm_lang$core$List$drop = F2(
	function (n, list) {
		drop:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(n, 0) < 1) {
				return list;
			} else {
				var _p0 = list;
				if (_p0.ctor === '[]') {
					return list;
				} else {
					var _v1 = n - 1,
						_v2 = _p0._1;
					n = _v1;
					list = _v2;
					continue drop;
				}
			}
		}
	});
var _elm_lang$core$List$map5 = _elm_lang$core$Native_List.map5;
var _elm_lang$core$List$map4 = _elm_lang$core$Native_List.map4;
var _elm_lang$core$List$map3 = _elm_lang$core$Native_List.map3;
var _elm_lang$core$List$map2 = _elm_lang$core$Native_List.map2;
var _elm_lang$core$List$any = F2(
	function (isOkay, list) {
		any:
		while (true) {
			var _p1 = list;
			if (_p1.ctor === '[]') {
				return false;
			} else {
				if (isOkay(_p1._0)) {
					return true;
				} else {
					var _v4 = isOkay,
						_v5 = _p1._1;
					isOkay = _v4;
					list = _v5;
					continue any;
				}
			}
		}
	});
var _elm_lang$core$List$all = F2(
	function (isOkay, list) {
		return !A2(
			_elm_lang$core$List$any,
			function (_p2) {
				return !isOkay(_p2);
			},
			list);
	});
var _elm_lang$core$List$foldr = _elm_lang$core$Native_List.foldr;
var _elm_lang$core$List$foldl = F3(
	function (func, acc, list) {
		foldl:
		while (true) {
			var _p3 = list;
			if (_p3.ctor === '[]') {
				return acc;
			} else {
				var _v7 = func,
					_v8 = A2(func, _p3._0, acc),
					_v9 = _p3._1;
				func = _v7;
				acc = _v8;
				list = _v9;
				continue foldl;
			}
		}
	});
var _elm_lang$core$List$length = function (xs) {
	return A3(
		_elm_lang$core$List$foldl,
		F2(
			function (_p4, i) {
				return i + 1;
			}),
		0,
		xs);
};
var _elm_lang$core$List$sum = function (numbers) {
	return A3(
		_elm_lang$core$List$foldl,
		F2(
			function (x, y) {
				return x + y;
			}),
		0,
		numbers);
};
var _elm_lang$core$List$product = function (numbers) {
	return A3(
		_elm_lang$core$List$foldl,
		F2(
			function (x, y) {
				return x * y;
			}),
		1,
		numbers);
};
var _elm_lang$core$List$maximum = function (list) {
	var _p5 = list;
	if (_p5.ctor === '::') {
		return _elm_lang$core$Maybe$Just(
			A3(_elm_lang$core$List$foldl, _elm_lang$core$Basics$max, _p5._0, _p5._1));
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _elm_lang$core$List$minimum = function (list) {
	var _p6 = list;
	if (_p6.ctor === '::') {
		return _elm_lang$core$Maybe$Just(
			A3(_elm_lang$core$List$foldl, _elm_lang$core$Basics$min, _p6._0, _p6._1));
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _elm_lang$core$List$member = F2(
	function (x, xs) {
		return A2(
			_elm_lang$core$List$any,
			function (a) {
				return _elm_lang$core$Native_Utils.eq(a, x);
			},
			xs);
	});
var _elm_lang$core$List$isEmpty = function (xs) {
	var _p7 = xs;
	if (_p7.ctor === '[]') {
		return true;
	} else {
		return false;
	}
};
var _elm_lang$core$List$tail = function (list) {
	var _p8 = list;
	if (_p8.ctor === '::') {
		return _elm_lang$core$Maybe$Just(_p8._1);
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _elm_lang$core$List$head = function (list) {
	var _p9 = list;
	if (_p9.ctor === '::') {
		return _elm_lang$core$Maybe$Just(_p9._0);
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _elm_lang$core$List_ops = _elm_lang$core$List_ops || {};
_elm_lang$core$List_ops['::'] = _elm_lang$core$Native_List.cons;
var _elm_lang$core$List$map = F2(
	function (f, xs) {
		return A3(
			_elm_lang$core$List$foldr,
			F2(
				function (x, acc) {
					return {
						ctor: '::',
						_0: f(x),
						_1: acc
					};
				}),
			{ctor: '[]'},
			xs);
	});
var _elm_lang$core$List$filter = F2(
	function (pred, xs) {
		var conditionalCons = F2(
			function (front, back) {
				return pred(front) ? {ctor: '::', _0: front, _1: back} : back;
			});
		return A3(
			_elm_lang$core$List$foldr,
			conditionalCons,
			{ctor: '[]'},
			xs);
	});
var _elm_lang$core$List$maybeCons = F3(
	function (f, mx, xs) {
		var _p10 = f(mx);
		if (_p10.ctor === 'Just') {
			return {ctor: '::', _0: _p10._0, _1: xs};
		} else {
			return xs;
		}
	});
var _elm_lang$core$List$filterMap = F2(
	function (f, xs) {
		return A3(
			_elm_lang$core$List$foldr,
			_elm_lang$core$List$maybeCons(f),
			{ctor: '[]'},
			xs);
	});
var _elm_lang$core$List$reverse = function (list) {
	return A3(
		_elm_lang$core$List$foldl,
		F2(
			function (x, y) {
				return {ctor: '::', _0: x, _1: y};
			}),
		{ctor: '[]'},
		list);
};
var _elm_lang$core$List$scanl = F3(
	function (f, b, xs) {
		var scan1 = F2(
			function (x, accAcc) {
				var _p11 = accAcc;
				if (_p11.ctor === '::') {
					return {
						ctor: '::',
						_0: A2(f, x, _p11._0),
						_1: accAcc
					};
				} else {
					return {ctor: '[]'};
				}
			});
		return _elm_lang$core$List$reverse(
			A3(
				_elm_lang$core$List$foldl,
				scan1,
				{
					ctor: '::',
					_0: b,
					_1: {ctor: '[]'}
				},
				xs));
	});
var _elm_lang$core$List$append = F2(
	function (xs, ys) {
		var _p12 = ys;
		if (_p12.ctor === '[]') {
			return xs;
		} else {
			return A3(
				_elm_lang$core$List$foldr,
				F2(
					function (x, y) {
						return {ctor: '::', _0: x, _1: y};
					}),
				ys,
				xs);
		}
	});
var _elm_lang$core$List$concat = function (lists) {
	return A3(
		_elm_lang$core$List$foldr,
		_elm_lang$core$List$append,
		{ctor: '[]'},
		lists);
};
var _elm_lang$core$List$concatMap = F2(
	function (f, list) {
		return _elm_lang$core$List$concat(
			A2(_elm_lang$core$List$map, f, list));
	});
var _elm_lang$core$List$partition = F2(
	function (pred, list) {
		var step = F2(
			function (x, _p13) {
				var _p14 = _p13;
				var _p16 = _p14._0;
				var _p15 = _p14._1;
				return pred(x) ? {
					ctor: '_Tuple2',
					_0: {ctor: '::', _0: x, _1: _p16},
					_1: _p15
				} : {
					ctor: '_Tuple2',
					_0: _p16,
					_1: {ctor: '::', _0: x, _1: _p15}
				};
			});
		return A3(
			_elm_lang$core$List$foldr,
			step,
			{
				ctor: '_Tuple2',
				_0: {ctor: '[]'},
				_1: {ctor: '[]'}
			},
			list);
	});
var _elm_lang$core$List$unzip = function (pairs) {
	var step = F2(
		function (_p18, _p17) {
			var _p19 = _p18;
			var _p20 = _p17;
			return {
				ctor: '_Tuple2',
				_0: {ctor: '::', _0: _p19._0, _1: _p20._0},
				_1: {ctor: '::', _0: _p19._1, _1: _p20._1}
			};
		});
	return A3(
		_elm_lang$core$List$foldr,
		step,
		{
			ctor: '_Tuple2',
			_0: {ctor: '[]'},
			_1: {ctor: '[]'}
		},
		pairs);
};
var _elm_lang$core$List$intersperse = F2(
	function (sep, xs) {
		var _p21 = xs;
		if (_p21.ctor === '[]') {
			return {ctor: '[]'};
		} else {
			var step = F2(
				function (x, rest) {
					return {
						ctor: '::',
						_0: sep,
						_1: {ctor: '::', _0: x, _1: rest}
					};
				});
			var spersed = A3(
				_elm_lang$core$List$foldr,
				step,
				{ctor: '[]'},
				_p21._1);
			return {ctor: '::', _0: _p21._0, _1: spersed};
		}
	});
var _elm_lang$core$List$takeReverse = F3(
	function (n, list, taken) {
		takeReverse:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(n, 0) < 1) {
				return taken;
			} else {
				var _p22 = list;
				if (_p22.ctor === '[]') {
					return taken;
				} else {
					var _v23 = n - 1,
						_v24 = _p22._1,
						_v25 = {ctor: '::', _0: _p22._0, _1: taken};
					n = _v23;
					list = _v24;
					taken = _v25;
					continue takeReverse;
				}
			}
		}
	});
var _elm_lang$core$List$takeTailRec = F2(
	function (n, list) {
		return _elm_lang$core$List$reverse(
			A3(
				_elm_lang$core$List$takeReverse,
				n,
				list,
				{ctor: '[]'}));
	});
var _elm_lang$core$List$takeFast = F3(
	function (ctr, n, list) {
		if (_elm_lang$core$Native_Utils.cmp(n, 0) < 1) {
			return {ctor: '[]'};
		} else {
			var _p23 = {ctor: '_Tuple2', _0: n, _1: list};
			_v26_5:
			do {
				_v26_1:
				do {
					if (_p23.ctor === '_Tuple2') {
						if (_p23._1.ctor === '[]') {
							return list;
						} else {
							if (_p23._1._1.ctor === '::') {
								switch (_p23._0) {
									case 1:
										break _v26_1;
									case 2:
										return {
											ctor: '::',
											_0: _p23._1._0,
											_1: {
												ctor: '::',
												_0: _p23._1._1._0,
												_1: {ctor: '[]'}
											}
										};
									case 3:
										if (_p23._1._1._1.ctor === '::') {
											return {
												ctor: '::',
												_0: _p23._1._0,
												_1: {
													ctor: '::',
													_0: _p23._1._1._0,
													_1: {
														ctor: '::',
														_0: _p23._1._1._1._0,
														_1: {ctor: '[]'}
													}
												}
											};
										} else {
											break _v26_5;
										}
									default:
										if ((_p23._1._1._1.ctor === '::') && (_p23._1._1._1._1.ctor === '::')) {
											var _p28 = _p23._1._1._1._0;
											var _p27 = _p23._1._1._0;
											var _p26 = _p23._1._0;
											var _p25 = _p23._1._1._1._1._0;
											var _p24 = _p23._1._1._1._1._1;
											return (_elm_lang$core$Native_Utils.cmp(ctr, 1000) > 0) ? {
												ctor: '::',
												_0: _p26,
												_1: {
													ctor: '::',
													_0: _p27,
													_1: {
														ctor: '::',
														_0: _p28,
														_1: {
															ctor: '::',
															_0: _p25,
															_1: A2(_elm_lang$core$List$takeTailRec, n - 4, _p24)
														}
													}
												}
											} : {
												ctor: '::',
												_0: _p26,
												_1: {
													ctor: '::',
													_0: _p27,
													_1: {
														ctor: '::',
														_0: _p28,
														_1: {
															ctor: '::',
															_0: _p25,
															_1: A3(_elm_lang$core$List$takeFast, ctr + 1, n - 4, _p24)
														}
													}
												}
											};
										} else {
											break _v26_5;
										}
								}
							} else {
								if (_p23._0 === 1) {
									break _v26_1;
								} else {
									break _v26_5;
								}
							}
						}
					} else {
						break _v26_5;
					}
				} while(false);
				return {
					ctor: '::',
					_0: _p23._1._0,
					_1: {ctor: '[]'}
				};
			} while(false);
			return list;
		}
	});
var _elm_lang$core$List$take = F2(
	function (n, list) {
		return A3(_elm_lang$core$List$takeFast, 0, n, list);
	});
var _elm_lang$core$List$repeatHelp = F3(
	function (result, n, value) {
		repeatHelp:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(n, 0) < 1) {
				return result;
			} else {
				var _v27 = {ctor: '::', _0: value, _1: result},
					_v28 = n - 1,
					_v29 = value;
				result = _v27;
				n = _v28;
				value = _v29;
				continue repeatHelp;
			}
		}
	});
var _elm_lang$core$List$repeat = F2(
	function (n, value) {
		return A3(
			_elm_lang$core$List$repeatHelp,
			{ctor: '[]'},
			n,
			value);
	});
var _elm_lang$core$List$rangeHelp = F3(
	function (lo, hi, list) {
		rangeHelp:
		while (true) {
			if (_elm_lang$core$Native_Utils.cmp(lo, hi) < 1) {
				var _v30 = lo,
					_v31 = hi - 1,
					_v32 = {ctor: '::', _0: hi, _1: list};
				lo = _v30;
				hi = _v31;
				list = _v32;
				continue rangeHelp;
			} else {
				return list;
			}
		}
	});
var _elm_lang$core$List$range = F2(
	function (lo, hi) {
		return A3(
			_elm_lang$core$List$rangeHelp,
			lo,
			hi,
			{ctor: '[]'});
	});
var _elm_lang$core$List$indexedMap = F2(
	function (f, xs) {
		return A3(
			_elm_lang$core$List$map2,
			f,
			A2(
				_elm_lang$core$List$range,
				0,
				_elm_lang$core$List$length(xs) - 1),
			xs);
	});

var _elm_lang$core$Array$append = _elm_lang$core$Native_Array.append;
var _elm_lang$core$Array$length = _elm_lang$core$Native_Array.length;
var _elm_lang$core$Array$isEmpty = function (array) {
	return _elm_lang$core$Native_Utils.eq(
		_elm_lang$core$Array$length(array),
		0);
};
var _elm_lang$core$Array$slice = _elm_lang$core$Native_Array.slice;
var _elm_lang$core$Array$set = _elm_lang$core$Native_Array.set;
var _elm_lang$core$Array$get = F2(
	function (i, array) {
		return ((_elm_lang$core$Native_Utils.cmp(0, i) < 1) && (_elm_lang$core$Native_Utils.cmp(
			i,
			_elm_lang$core$Native_Array.length(array)) < 0)) ? _elm_lang$core$Maybe$Just(
			A2(_elm_lang$core$Native_Array.get, i, array)) : _elm_lang$core$Maybe$Nothing;
	});
var _elm_lang$core$Array$push = _elm_lang$core$Native_Array.push;
var _elm_lang$core$Array$empty = _elm_lang$core$Native_Array.empty;
var _elm_lang$core$Array$filter = F2(
	function (isOkay, arr) {
		var update = F2(
			function (x, xs) {
				return isOkay(x) ? A2(_elm_lang$core$Native_Array.push, x, xs) : xs;
			});
		return A3(_elm_lang$core$Native_Array.foldl, update, _elm_lang$core$Native_Array.empty, arr);
	});
var _elm_lang$core$Array$foldr = _elm_lang$core$Native_Array.foldr;
var _elm_lang$core$Array$foldl = _elm_lang$core$Native_Array.foldl;
var _elm_lang$core$Array$indexedMap = _elm_lang$core$Native_Array.indexedMap;
var _elm_lang$core$Array$map = _elm_lang$core$Native_Array.map;
var _elm_lang$core$Array$toIndexedList = function (array) {
	return A3(
		_elm_lang$core$List$map2,
		F2(
			function (v0, v1) {
				return {ctor: '_Tuple2', _0: v0, _1: v1};
			}),
		A2(
			_elm_lang$core$List$range,
			0,
			_elm_lang$core$Native_Array.length(array) - 1),
		_elm_lang$core$Native_Array.toList(array));
};
var _elm_lang$core$Array$toList = _elm_lang$core$Native_Array.toList;
var _elm_lang$core$Array$fromList = _elm_lang$core$Native_Array.fromList;
var _elm_lang$core$Array$initialize = _elm_lang$core$Native_Array.initialize;
var _elm_lang$core$Array$repeat = F2(
	function (n, e) {
		return A2(
			_elm_lang$core$Array$initialize,
			n,
			_elm_lang$core$Basics$always(e));
	});
var _elm_lang$core$Array$Array = {ctor: 'Array'};

//import Native.Utils //

var _elm_lang$core$Native_Debug = function() {

function log(tag, value)
{
	var msg = tag + ': ' + _elm_lang$core$Native_Utils.toString(value);
	var process = process || {};
	if (process.stdout)
	{
		process.stdout.write(msg);
	}
	else
	{
		console.log(msg);
	}
	return value;
}

function crash(message)
{
	throw new Error(message);
}

return {
	crash: crash,
	log: F2(log)
};

}();
//import Maybe, Native.List, Native.Utils, Result //

var _elm_lang$core$Native_String = function() {

function isEmpty(str)
{
	return str.length === 0;
}
function cons(chr, str)
{
	return chr + str;
}
function uncons(str)
{
	var hd = str[0];
	if (hd)
	{
		return _elm_lang$core$Maybe$Just(_elm_lang$core$Native_Utils.Tuple2(_elm_lang$core$Native_Utils.chr(hd), str.slice(1)));
	}
	return _elm_lang$core$Maybe$Nothing;
}
function append(a, b)
{
	return a + b;
}
function concat(strs)
{
	return _elm_lang$core$Native_List.toArray(strs).join('');
}
function length(str)
{
	return str.length;
}
function map(f, str)
{
	var out = str.split('');
	for (var i = out.length; i--; )
	{
		out[i] = f(_elm_lang$core$Native_Utils.chr(out[i]));
	}
	return out.join('');
}
function filter(pred, str)
{
	return str.split('').map(_elm_lang$core$Native_Utils.chr).filter(pred).join('');
}
function reverse(str)
{
	return str.split('').reverse().join('');
}
function foldl(f, b, str)
{
	var len = str.length;
	for (var i = 0; i < len; ++i)
	{
		b = A2(f, _elm_lang$core$Native_Utils.chr(str[i]), b);
	}
	return b;
}
function foldr(f, b, str)
{
	for (var i = str.length; i--; )
	{
		b = A2(f, _elm_lang$core$Native_Utils.chr(str[i]), b);
	}
	return b;
}
function split(sep, str)
{
	return _elm_lang$core$Native_List.fromArray(str.split(sep));
}
function join(sep, strs)
{
	return _elm_lang$core$Native_List.toArray(strs).join(sep);
}
function repeat(n, str)
{
	var result = '';
	while (n > 0)
	{
		if (n & 1)
		{
			result += str;
		}
		n >>= 1, str += str;
	}
	return result;
}
function slice(start, end, str)
{
	return str.slice(start, end);
}
function left(n, str)
{
	return n < 1 ? '' : str.slice(0, n);
}
function right(n, str)
{
	return n < 1 ? '' : str.slice(-n);
}
function dropLeft(n, str)
{
	return n < 1 ? str : str.slice(n);
}
function dropRight(n, str)
{
	return n < 1 ? str : str.slice(0, -n);
}
function pad(n, chr, str)
{
	var half = (n - str.length) / 2;
	return repeat(Math.ceil(half), chr) + str + repeat(half | 0, chr);
}
function padRight(n, chr, str)
{
	return str + repeat(n - str.length, chr);
}
function padLeft(n, chr, str)
{
	return repeat(n - str.length, chr) + str;
}

function trim(str)
{
	return str.trim();
}
function trimLeft(str)
{
	return str.replace(/^\s+/, '');
}
function trimRight(str)
{
	return str.replace(/\s+$/, '');
}

function words(str)
{
	return _elm_lang$core$Native_List.fromArray(str.trim().split(/\s+/g));
}
function lines(str)
{
	return _elm_lang$core$Native_List.fromArray(str.split(/\r\n|\r|\n/g));
}

function toUpper(str)
{
	return str.toUpperCase();
}
function toLower(str)
{
	return str.toLowerCase();
}

function any(pred, str)
{
	for (var i = str.length; i--; )
	{
		if (pred(_elm_lang$core$Native_Utils.chr(str[i])))
		{
			return true;
		}
	}
	return false;
}
function all(pred, str)
{
	for (var i = str.length; i--; )
	{
		if (!pred(_elm_lang$core$Native_Utils.chr(str[i])))
		{
			return false;
		}
	}
	return true;
}

function contains(sub, str)
{
	return str.indexOf(sub) > -1;
}
function startsWith(sub, str)
{
	return str.indexOf(sub) === 0;
}
function endsWith(sub, str)
{
	return str.length >= sub.length &&
		str.lastIndexOf(sub) === str.length - sub.length;
}
function indexes(sub, str)
{
	var subLen = sub.length;
	
	if (subLen < 1)
	{
		return _elm_lang$core$Native_List.Nil;
	}

	var i = 0;
	var is = [];

	while ((i = str.indexOf(sub, i)) > -1)
	{
		is.push(i);
		i = i + subLen;
	}	
	
	return _elm_lang$core$Native_List.fromArray(is);
}

function toInt(s)
{
	var len = s.length;
	if (len === 0)
	{
		return _elm_lang$core$Result$Err("could not convert string '" + s + "' to an Int" );
	}
	var start = 0;
	if (s[0] === '-')
	{
		if (len === 1)
		{
			return _elm_lang$core$Result$Err("could not convert string '" + s + "' to an Int" );
		}
		start = 1;
	}
	for (var i = start; i < len; ++i)
	{
		var c = s[i];
		if (c < '0' || '9' < c)
		{
			return _elm_lang$core$Result$Err("could not convert string '" + s + "' to an Int" );
		}
	}
	return _elm_lang$core$Result$Ok(parseInt(s, 10));
}

function toFloat(s)
{
	var len = s.length;
	if (len === 0)
	{
		return _elm_lang$core$Result$Err("could not convert string '" + s + "' to a Float" );
	}
	var start = 0;
	if (s[0] === '-')
	{
		if (len === 1)
		{
			return _elm_lang$core$Result$Err("could not convert string '" + s + "' to a Float" );
		}
		start = 1;
	}
	var dotCount = 0;
	for (var i = start; i < len; ++i)
	{
		var c = s[i];
		if ('0' <= c && c <= '9')
		{
			continue;
		}
		if (c === '.')
		{
			dotCount += 1;
			if (dotCount <= 1)
			{
				continue;
			}
		}
		return _elm_lang$core$Result$Err("could not convert string '" + s + "' to a Float" );
	}
	return _elm_lang$core$Result$Ok(parseFloat(s));
}

function toList(str)
{
	return _elm_lang$core$Native_List.fromArray(str.split('').map(_elm_lang$core$Native_Utils.chr));
}
function fromList(chars)
{
	return _elm_lang$core$Native_List.toArray(chars).join('');
}

return {
	isEmpty: isEmpty,
	cons: F2(cons),
	uncons: uncons,
	append: F2(append),
	concat: concat,
	length: length,
	map: F2(map),
	filter: F2(filter),
	reverse: reverse,
	foldl: F3(foldl),
	foldr: F3(foldr),

	split: F2(split),
	join: F2(join),
	repeat: F2(repeat),

	slice: F3(slice),
	left: F2(left),
	right: F2(right),
	dropLeft: F2(dropLeft),
	dropRight: F2(dropRight),

	pad: F3(pad),
	padLeft: F3(padLeft),
	padRight: F3(padRight),

	trim: trim,
	trimLeft: trimLeft,
	trimRight: trimRight,

	words: words,
	lines: lines,

	toUpper: toUpper,
	toLower: toLower,

	any: F2(any),
	all: F2(all),

	contains: F2(contains),
	startsWith: F2(startsWith),
	endsWith: F2(endsWith),
	indexes: F2(indexes),

	toInt: toInt,
	toFloat: toFloat,
	toList: toList,
	fromList: fromList
};

}();

//import Native.Utils //

var _elm_lang$core$Native_Char = function() {

return {
	fromCode: function(c) { return _elm_lang$core$Native_Utils.chr(String.fromCharCode(c)); },
	toCode: function(c) { return c.charCodeAt(0); },
	toUpper: function(c) { return _elm_lang$core$Native_Utils.chr(c.toUpperCase()); },
	toLower: function(c) { return _elm_lang$core$Native_Utils.chr(c.toLowerCase()); },
	toLocaleUpper: function(c) { return _elm_lang$core$Native_Utils.chr(c.toLocaleUpperCase()); },
	toLocaleLower: function(c) { return _elm_lang$core$Native_Utils.chr(c.toLocaleLowerCase()); }
};

}();
var _elm_lang$core$Char$fromCode = _elm_lang$core$Native_Char.fromCode;
var _elm_lang$core$Char$toCode = _elm_lang$core$Native_Char.toCode;
var _elm_lang$core$Char$toLocaleLower = _elm_lang$core$Native_Char.toLocaleLower;
var _elm_lang$core$Char$toLocaleUpper = _elm_lang$core$Native_Char.toLocaleUpper;
var _elm_lang$core$Char$toLower = _elm_lang$core$Native_Char.toLower;
var _elm_lang$core$Char$toUpper = _elm_lang$core$Native_Char.toUpper;
var _elm_lang$core$Char$isBetween = F3(
	function (low, high, $char) {
		var code = _elm_lang$core$Char$toCode($char);
		return (_elm_lang$core$Native_Utils.cmp(
			code,
			_elm_lang$core$Char$toCode(low)) > -1) && (_elm_lang$core$Native_Utils.cmp(
			code,
			_elm_lang$core$Char$toCode(high)) < 1);
	});
var _elm_lang$core$Char$isUpper = A2(
	_elm_lang$core$Char$isBetween,
	_elm_lang$core$Native_Utils.chr('A'),
	_elm_lang$core$Native_Utils.chr('Z'));
var _elm_lang$core$Char$isLower = A2(
	_elm_lang$core$Char$isBetween,
	_elm_lang$core$Native_Utils.chr('a'),
	_elm_lang$core$Native_Utils.chr('z'));
var _elm_lang$core$Char$isDigit = A2(
	_elm_lang$core$Char$isBetween,
	_elm_lang$core$Native_Utils.chr('0'),
	_elm_lang$core$Native_Utils.chr('9'));
var _elm_lang$core$Char$isOctDigit = A2(
	_elm_lang$core$Char$isBetween,
	_elm_lang$core$Native_Utils.chr('0'),
	_elm_lang$core$Native_Utils.chr('7'));
var _elm_lang$core$Char$isHexDigit = function ($char) {
	return _elm_lang$core$Char$isDigit($char) || (A3(
		_elm_lang$core$Char$isBetween,
		_elm_lang$core$Native_Utils.chr('a'),
		_elm_lang$core$Native_Utils.chr('f'),
		$char) || A3(
		_elm_lang$core$Char$isBetween,
		_elm_lang$core$Native_Utils.chr('A'),
		_elm_lang$core$Native_Utils.chr('F'),
		$char));
};

var _elm_lang$core$Result$toMaybe = function (result) {
	var _p0 = result;
	if (_p0.ctor === 'Ok') {
		return _elm_lang$core$Maybe$Just(_p0._0);
	} else {
		return _elm_lang$core$Maybe$Nothing;
	}
};
var _elm_lang$core$Result$withDefault = F2(
	function (def, result) {
		var _p1 = result;
		if (_p1.ctor === 'Ok') {
			return _p1._0;
		} else {
			return def;
		}
	});
var _elm_lang$core$Result$Err = function (a) {
	return {ctor: 'Err', _0: a};
};
var _elm_lang$core$Result$andThen = F2(
	function (callback, result) {
		var _p2 = result;
		if (_p2.ctor === 'Ok') {
			return callback(_p2._0);
		} else {
			return _elm_lang$core$Result$Err(_p2._0);
		}
	});
var _elm_lang$core$Result$Ok = function (a) {
	return {ctor: 'Ok', _0: a};
};
var _elm_lang$core$Result$map = F2(
	function (func, ra) {
		var _p3 = ra;
		if (_p3.ctor === 'Ok') {
			return _elm_lang$core$Result$Ok(
				func(_p3._0));
		} else {
			return _elm_lang$core$Result$Err(_p3._0);
		}
	});
var _elm_lang$core$Result$map2 = F3(
	function (func, ra, rb) {
		var _p4 = {ctor: '_Tuple2', _0: ra, _1: rb};
		if (_p4._0.ctor === 'Ok') {
			if (_p4._1.ctor === 'Ok') {
				return _elm_lang$core$Result$Ok(
					A2(func, _p4._0._0, _p4._1._0));
			} else {
				return _elm_lang$core$Result$Err(_p4._1._0);
			}
		} else {
			return _elm_lang$core$Result$Err(_p4._0._0);
		}
	});
var _elm_lang$core$Result$map3 = F4(
	function (func, ra, rb, rc) {
		var _p5 = {ctor: '_Tuple3', _0: ra, _1: rb, _2: rc};
		if (_p5._0.ctor === 'Ok') {
			if (_p5._1.ctor === 'Ok') {
				if (_p5._2.ctor === 'Ok') {
					return _elm_lang$core$Result$Ok(
						A3(func, _p5._0._0, _p5._1._0, _p5._2._0));
				} else {
					return _elm_lang$core$Result$Err(_p5._2._0);
				}
			} else {
				return _elm_lang$core$Result$Err(_p5._1._0);
			}
		} else {
			return _elm_lang$core$Result$Err(_p5._0._0);
		}
	});
var _elm_lang$core$Result$map4 = F5(
	function (func, ra, rb, rc, rd) {
		var _p6 = {ctor: '_Tuple4', _0: ra, _1: rb, _2: rc, _3: rd};
		if (_p6._0.ctor === 'Ok') {
			if (_p6._1.ctor === 'Ok') {
				if (_p6._2.ctor === 'Ok') {
					if (_p6._3.ctor === 'Ok') {
						return _elm_lang$core$Result$Ok(
							A4(func, _p6._0._0, _p6._1._0, _p6._2._0, _p6._3._0));
					} else {
						return _elm_lang$core$Result$Err(_p6._3._0);
					}
				} else {
					return _elm_lang$core$Result$Err(_p6._2._0);
				}
			} else {
				return _elm_lang$core$Result$Err(_p6._1._0);
			}
		} else {
			return _elm_lang$core$Result$Err(_p6._0._0);
		}
	});
var _elm_lang$core$Result$map5 = F6(
	function (func, ra, rb, rc, rd, re) {
		var _p7 = {ctor: '_Tuple5', _0: ra, _1: rb, _2: rc, _3: rd, _4: re};
		if (_p7._0.ctor === 'Ok') {
			if (_p7._1.ctor === 'Ok') {
				if (_p7._2.ctor === 'Ok') {
					if (_p7._3.ctor === 'Ok') {
						if (_p7._4.ctor === 'Ok') {
							return _elm_lang$core$Result$Ok(
								A5(func, _p7._0._0, _p7._1._0, _p7._2._0, _p7._3._0, _p7._4._0));
						} else {
							return _elm_lang$core$Result$Err(_p7._4._0);
						}
					} else {
						return _elm_lang$core$Result$Err(_p7._3._0);
					}
				} else {
					return _elm_lang$core$Result$Err(_p7._2._0);
				}
			} else {
				return _elm_lang$core$Result$Err(_p7._1._0);
			}
		} else {
			return _elm_lang$core$Result$Err(_p7._0._0);
		}
	});
var _elm_lang$core$Result$mapError = F2(
	function (f, result) {
		var _p8 = result;
		if (_p8.ctor === 'Ok') {
			return _elm_lang$core$Result$Ok(_p8._0);
		} else {
			return _elm_lang$core$Result$Err(
				f(_p8._0));
		}
	});
var _elm_lang$core$Result$fromMaybe = F2(
	function (err, maybe) {
		var _p9 = maybe;
		if (_p9.ctor === 'Just') {
			return _elm_lang$core$Result$Ok(_p9._0);
		} else {
			return _elm_lang$core$Result$Err(err);
		}
	});

var _elm_lang$core$String$fromList = _elm_lang$core$Native_String.fromList;
var _elm_lang$core$String$toList = _elm_lang$core$Native_String.toList;
var _elm_lang$core$String$toFloat = _elm_lang$core$Native_String.toFloat;
var _elm_lang$core$String$toInt = _elm_lang$core$Native_String.toInt;
var _elm_lang$core$String$indices = _elm_lang$core$Native_String.indexes;
var _elm_lang$core$String$indexes = _elm_lang$core$Native_String.indexes;
var _elm_lang$core$String$endsWith = _elm_lang$core$Native_String.endsWith;
var _elm_lang$core$String$startsWith = _elm_lang$core$Native_String.startsWith;
var _elm_lang$core$String$contains = _elm_lang$core$Native_String.contains;
var _elm_lang$core$String$all = _elm_lang$core$Native_String.all;
var _elm_lang$core$String$any = _elm_lang$core$Native_String.any;
var _elm_lang$core$String$toLower = _elm_lang$core$Native_String.toLower;
var _elm_lang$core$String$toUpper = _elm_lang$core$Native_String.toUpper;
var _elm_lang$core$String$lines = _elm_lang$core$Native_String.lines;
var _elm_lang$core$String$words = _elm_lang$core$Native_String.words;
var _elm_lang$core$String$trimRight = _elm_lang$core$Native_String.trimRight;
var _elm_lang$core$String$trimLeft = _elm_lang$core$Native_String.trimLeft;
var _elm_lang$core$String$trim = _elm_lang$core$Native_String.trim;
var _elm_lang$core$String$padRight = _elm_lang$core$Native_String.padRight;
var _elm_lang$core$String$padLeft = _elm_lang$core$Native_String.padLeft;
var _elm_lang$core$String$pad = _elm_lang$core$Native_String.pad;
var _elm_lang$core$String$dropRight = _elm_lang$core$Native_String.dropRight;
var _elm_lang$core$String$dropLeft = _elm_lang$core$Native_String.dropLeft;
var _elm_lang$core$String$right = _elm_lang$core$Native_String.right;
var _elm_lang$core$String$left = _elm_lang$core$Native_String.left;
var _elm_lang$core$String$slice = _elm_lang$core$Native_String.slice;
var _elm_lang$core$String$repeat = _elm_lang$core$Native_String.repeat;
var _elm_lang$core$String$join = _elm_lang$core$Native_String.join;
var _elm_lang$core$String$split = _elm_lang$core$Native_String.split;
var _elm_lang$core$String$foldr = _elm_lang$core$Native_String.foldr;
var _elm_lang$core$String$foldl = _elm_lang$core$Native_String.foldl;
var _elm_lang$core$String$reverse = _elm_lang$core$Native_String.reverse;
var _elm_lang$core$String$filter = _elm_lang$core$Native_String.filter;
var _elm_lang$core$String$map = _elm_lang$core$Native_String.map;
var _elm_lang$core$String$length = _elm_lang$core$Native_String.length;
var _elm_lang$core$String$concat = _elm_lang$core$Native_String.concat;
var _elm_lang$core$String$append = _elm_lang$core$Native_String.append;
var _elm_lang$core$String$uncons = _elm_lang$core$Native_String.uncons;
var _elm_lang$core$String$cons = _elm_lang$core$Native_String.cons;
var _elm_lang$core$String$fromChar = function ($char) {
	return A2(_elm_lang$core$String$cons, $char, '');
};
var _elm_lang$core$String$isEmpty = _elm_lang$core$Native_String.isEmpty;

var _elm_lang$core$Dict$foldr = F3(
	function (f, acc, t) {
		foldr:
		while (true) {
			var _p0 = t;
			if (_p0.ctor === 'RBEmpty_elm_builtin') {
				return acc;
			} else {
				var _v1 = f,
					_v2 = A3(
					f,
					_p0._1,
					_p0._2,
					A3(_elm_lang$core$Dict$foldr, f, acc, _p0._4)),
					_v3 = _p0._3;
				f = _v1;
				acc = _v2;
				t = _v3;
				continue foldr;
			}
		}
	});
var _elm_lang$core$Dict$keys = function (dict) {
	return A3(
		_elm_lang$core$Dict$foldr,
		F3(
			function (key, value, keyList) {
				return {ctor: '::', _0: key, _1: keyList};
			}),
		{ctor: '[]'},
		dict);
};
var _elm_lang$core$Dict$values = function (dict) {
	return A3(
		_elm_lang$core$Dict$foldr,
		F3(
			function (key, value, valueList) {
				return {ctor: '::', _0: value, _1: valueList};
			}),
		{ctor: '[]'},
		dict);
};
var _elm_lang$core$Dict$toList = function (dict) {
	return A3(
		_elm_lang$core$Dict$foldr,
		F3(
			function (key, value, list) {
				return {
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: key, _1: value},
					_1: list
				};
			}),
		{ctor: '[]'},
		dict);
};
var _elm_lang$core$Dict$foldl = F3(
	function (f, acc, dict) {
		foldl:
		while (true) {
			var _p1 = dict;
			if (_p1.ctor === 'RBEmpty_elm_builtin') {
				return acc;
			} else {
				var _v5 = f,
					_v6 = A3(
					f,
					_p1._1,
					_p1._2,
					A3(_elm_lang$core$Dict$foldl, f, acc, _p1._3)),
					_v7 = _p1._4;
				f = _v5;
				acc = _v6;
				dict = _v7;
				continue foldl;
			}
		}
	});
var _elm_lang$core$Dict$merge = F6(
	function (leftStep, bothStep, rightStep, leftDict, rightDict, initialResult) {
		var stepState = F3(
			function (rKey, rValue, _p2) {
				stepState:
				while (true) {
					var _p3 = _p2;
					var _p9 = _p3._1;
					var _p8 = _p3._0;
					var _p4 = _p8;
					if (_p4.ctor === '[]') {
						return {
							ctor: '_Tuple2',
							_0: _p8,
							_1: A3(rightStep, rKey, rValue, _p9)
						};
					} else {
						var _p7 = _p4._1;
						var _p6 = _p4._0._1;
						var _p5 = _p4._0._0;
						if (_elm_lang$core$Native_Utils.cmp(_p5, rKey) < 0) {
							var _v10 = rKey,
								_v11 = rValue,
								_v12 = {
								ctor: '_Tuple2',
								_0: _p7,
								_1: A3(leftStep, _p5, _p6, _p9)
							};
							rKey = _v10;
							rValue = _v11;
							_p2 = _v12;
							continue stepState;
						} else {
							if (_elm_lang$core$Native_Utils.cmp(_p5, rKey) > 0) {
								return {
									ctor: '_Tuple2',
									_0: _p8,
									_1: A3(rightStep, rKey, rValue, _p9)
								};
							} else {
								return {
									ctor: '_Tuple2',
									_0: _p7,
									_1: A4(bothStep, _p5, _p6, rValue, _p9)
								};
							}
						}
					}
				}
			});
		var _p10 = A3(
			_elm_lang$core$Dict$foldl,
			stepState,
			{
				ctor: '_Tuple2',
				_0: _elm_lang$core$Dict$toList(leftDict),
				_1: initialResult
			},
			rightDict);
		var leftovers = _p10._0;
		var intermediateResult = _p10._1;
		return A3(
			_elm_lang$core$List$foldl,
			F2(
				function (_p11, result) {
					var _p12 = _p11;
					return A3(leftStep, _p12._0, _p12._1, result);
				}),
			intermediateResult,
			leftovers);
	});
var _elm_lang$core$Dict$reportRemBug = F4(
	function (msg, c, lgot, rgot) {
		return _elm_lang$core$Native_Debug.crash(
			_elm_lang$core$String$concat(
				{
					ctor: '::',
					_0: 'Internal red-black tree invariant violated, expected ',
					_1: {
						ctor: '::',
						_0: msg,
						_1: {
							ctor: '::',
							_0: ' and got ',
							_1: {
								ctor: '::',
								_0: _elm_lang$core$Basics$toString(c),
								_1: {
									ctor: '::',
									_0: '/',
									_1: {
										ctor: '::',
										_0: lgot,
										_1: {
											ctor: '::',
											_0: '/',
											_1: {
												ctor: '::',
												_0: rgot,
												_1: {
													ctor: '::',
													_0: '\nPlease report this bug to <https://github.com/elm-lang/core/issues>',
													_1: {ctor: '[]'}
												}
											}
										}
									}
								}
							}
						}
					}
				}));
	});
var _elm_lang$core$Dict$isBBlack = function (dict) {
	var _p13 = dict;
	_v14_2:
	do {
		if (_p13.ctor === 'RBNode_elm_builtin') {
			if (_p13._0.ctor === 'BBlack') {
				return true;
			} else {
				break _v14_2;
			}
		} else {
			if (_p13._0.ctor === 'LBBlack') {
				return true;
			} else {
				break _v14_2;
			}
		}
	} while(false);
	return false;
};
var _elm_lang$core$Dict$sizeHelp = F2(
	function (n, dict) {
		sizeHelp:
		while (true) {
			var _p14 = dict;
			if (_p14.ctor === 'RBEmpty_elm_builtin') {
				return n;
			} else {
				var _v16 = A2(_elm_lang$core$Dict$sizeHelp, n + 1, _p14._4),
					_v17 = _p14._3;
				n = _v16;
				dict = _v17;
				continue sizeHelp;
			}
		}
	});
var _elm_lang$core$Dict$size = function (dict) {
	return A2(_elm_lang$core$Dict$sizeHelp, 0, dict);
};
var _elm_lang$core$Dict$get = F2(
	function (targetKey, dict) {
		get:
		while (true) {
			var _p15 = dict;
			if (_p15.ctor === 'RBEmpty_elm_builtin') {
				return _elm_lang$core$Maybe$Nothing;
			} else {
				var _p16 = A2(_elm_lang$core$Basics$compare, targetKey, _p15._1);
				switch (_p16.ctor) {
					case 'LT':
						var _v20 = targetKey,
							_v21 = _p15._3;
						targetKey = _v20;
						dict = _v21;
						continue get;
					case 'EQ':
						return _elm_lang$core$Maybe$Just(_p15._2);
					default:
						var _v22 = targetKey,
							_v23 = _p15._4;
						targetKey = _v22;
						dict = _v23;
						continue get;
				}
			}
		}
	});
var _elm_lang$core$Dict$member = F2(
	function (key, dict) {
		var _p17 = A2(_elm_lang$core$Dict$get, key, dict);
		if (_p17.ctor === 'Just') {
			return true;
		} else {
			return false;
		}
	});
var _elm_lang$core$Dict$maxWithDefault = F3(
	function (k, v, r) {
		maxWithDefault:
		while (true) {
			var _p18 = r;
			if (_p18.ctor === 'RBEmpty_elm_builtin') {
				return {ctor: '_Tuple2', _0: k, _1: v};
			} else {
				var _v26 = _p18._1,
					_v27 = _p18._2,
					_v28 = _p18._4;
				k = _v26;
				v = _v27;
				r = _v28;
				continue maxWithDefault;
			}
		}
	});
var _elm_lang$core$Dict$NBlack = {ctor: 'NBlack'};
var _elm_lang$core$Dict$BBlack = {ctor: 'BBlack'};
var _elm_lang$core$Dict$Black = {ctor: 'Black'};
var _elm_lang$core$Dict$blackish = function (t) {
	var _p19 = t;
	if (_p19.ctor === 'RBNode_elm_builtin') {
		var _p20 = _p19._0;
		return _elm_lang$core$Native_Utils.eq(_p20, _elm_lang$core$Dict$Black) || _elm_lang$core$Native_Utils.eq(_p20, _elm_lang$core$Dict$BBlack);
	} else {
		return true;
	}
};
var _elm_lang$core$Dict$Red = {ctor: 'Red'};
var _elm_lang$core$Dict$moreBlack = function (color) {
	var _p21 = color;
	switch (_p21.ctor) {
		case 'Black':
			return _elm_lang$core$Dict$BBlack;
		case 'Red':
			return _elm_lang$core$Dict$Black;
		case 'NBlack':
			return _elm_lang$core$Dict$Red;
		default:
			return _elm_lang$core$Native_Debug.crash('Can\'t make a double black node more black!');
	}
};
var _elm_lang$core$Dict$lessBlack = function (color) {
	var _p22 = color;
	switch (_p22.ctor) {
		case 'BBlack':
			return _elm_lang$core$Dict$Black;
		case 'Black':
			return _elm_lang$core$Dict$Red;
		case 'Red':
			return _elm_lang$core$Dict$NBlack;
		default:
			return _elm_lang$core$Native_Debug.crash('Can\'t make a negative black node less black!');
	}
};
var _elm_lang$core$Dict$LBBlack = {ctor: 'LBBlack'};
var _elm_lang$core$Dict$LBlack = {ctor: 'LBlack'};
var _elm_lang$core$Dict$RBEmpty_elm_builtin = function (a) {
	return {ctor: 'RBEmpty_elm_builtin', _0: a};
};
var _elm_lang$core$Dict$empty = _elm_lang$core$Dict$RBEmpty_elm_builtin(_elm_lang$core$Dict$LBlack);
var _elm_lang$core$Dict$isEmpty = function (dict) {
	return _elm_lang$core$Native_Utils.eq(dict, _elm_lang$core$Dict$empty);
};
var _elm_lang$core$Dict$RBNode_elm_builtin = F5(
	function (a, b, c, d, e) {
		return {ctor: 'RBNode_elm_builtin', _0: a, _1: b, _2: c, _3: d, _4: e};
	});
var _elm_lang$core$Dict$ensureBlackRoot = function (dict) {
	var _p23 = dict;
	if ((_p23.ctor === 'RBNode_elm_builtin') && (_p23._0.ctor === 'Red')) {
		return A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p23._1, _p23._2, _p23._3, _p23._4);
	} else {
		return dict;
	}
};
var _elm_lang$core$Dict$lessBlackTree = function (dict) {
	var _p24 = dict;
	if (_p24.ctor === 'RBNode_elm_builtin') {
		return A5(
			_elm_lang$core$Dict$RBNode_elm_builtin,
			_elm_lang$core$Dict$lessBlack(_p24._0),
			_p24._1,
			_p24._2,
			_p24._3,
			_p24._4);
	} else {
		return _elm_lang$core$Dict$RBEmpty_elm_builtin(_elm_lang$core$Dict$LBlack);
	}
};
var _elm_lang$core$Dict$balancedTree = function (col) {
	return function (xk) {
		return function (xv) {
			return function (yk) {
				return function (yv) {
					return function (zk) {
						return function (zv) {
							return function (a) {
								return function (b) {
									return function (c) {
										return function (d) {
											return A5(
												_elm_lang$core$Dict$RBNode_elm_builtin,
												_elm_lang$core$Dict$lessBlack(col),
												yk,
												yv,
												A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, xk, xv, a, b),
												A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, zk, zv, c, d));
										};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var _elm_lang$core$Dict$blacken = function (t) {
	var _p25 = t;
	if (_p25.ctor === 'RBEmpty_elm_builtin') {
		return _elm_lang$core$Dict$RBEmpty_elm_builtin(_elm_lang$core$Dict$LBlack);
	} else {
		return A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p25._1, _p25._2, _p25._3, _p25._4);
	}
};
var _elm_lang$core$Dict$redden = function (t) {
	var _p26 = t;
	if (_p26.ctor === 'RBEmpty_elm_builtin') {
		return _elm_lang$core$Native_Debug.crash('can\'t make a Leaf red');
	} else {
		return A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Red, _p26._1, _p26._2, _p26._3, _p26._4);
	}
};
var _elm_lang$core$Dict$balanceHelp = function (tree) {
	var _p27 = tree;
	_v36_6:
	do {
		_v36_5:
		do {
			_v36_4:
			do {
				_v36_3:
				do {
					_v36_2:
					do {
						_v36_1:
						do {
							_v36_0:
							do {
								if (_p27.ctor === 'RBNode_elm_builtin') {
									if (_p27._3.ctor === 'RBNode_elm_builtin') {
										if (_p27._4.ctor === 'RBNode_elm_builtin') {
											switch (_p27._3._0.ctor) {
												case 'Red':
													switch (_p27._4._0.ctor) {
														case 'Red':
															if ((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Red')) {
																break _v36_0;
															} else {
																if ((_p27._3._4.ctor === 'RBNode_elm_builtin') && (_p27._3._4._0.ctor === 'Red')) {
																	break _v36_1;
																} else {
																	if ((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Red')) {
																		break _v36_2;
																	} else {
																		if ((_p27._4._4.ctor === 'RBNode_elm_builtin') && (_p27._4._4._0.ctor === 'Red')) {
																			break _v36_3;
																		} else {
																			break _v36_6;
																		}
																	}
																}
															}
														case 'NBlack':
															if ((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Red')) {
																break _v36_0;
															} else {
																if ((_p27._3._4.ctor === 'RBNode_elm_builtin') && (_p27._3._4._0.ctor === 'Red')) {
																	break _v36_1;
																} else {
																	if (((((_p27._0.ctor === 'BBlack') && (_p27._4._3.ctor === 'RBNode_elm_builtin')) && (_p27._4._3._0.ctor === 'Black')) && (_p27._4._4.ctor === 'RBNode_elm_builtin')) && (_p27._4._4._0.ctor === 'Black')) {
																		break _v36_4;
																	} else {
																		break _v36_6;
																	}
																}
															}
														default:
															if ((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Red')) {
																break _v36_0;
															} else {
																if ((_p27._3._4.ctor === 'RBNode_elm_builtin') && (_p27._3._4._0.ctor === 'Red')) {
																	break _v36_1;
																} else {
																	break _v36_6;
																}
															}
													}
												case 'NBlack':
													switch (_p27._4._0.ctor) {
														case 'Red':
															if ((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Red')) {
																break _v36_2;
															} else {
																if ((_p27._4._4.ctor === 'RBNode_elm_builtin') && (_p27._4._4._0.ctor === 'Red')) {
																	break _v36_3;
																} else {
																	if (((((_p27._0.ctor === 'BBlack') && (_p27._3._3.ctor === 'RBNode_elm_builtin')) && (_p27._3._3._0.ctor === 'Black')) && (_p27._3._4.ctor === 'RBNode_elm_builtin')) && (_p27._3._4._0.ctor === 'Black')) {
																		break _v36_5;
																	} else {
																		break _v36_6;
																	}
																}
															}
														case 'NBlack':
															if (_p27._0.ctor === 'BBlack') {
																if ((((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Black')) && (_p27._4._4.ctor === 'RBNode_elm_builtin')) && (_p27._4._4._0.ctor === 'Black')) {
																	break _v36_4;
																} else {
																	if ((((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Black')) && (_p27._3._4.ctor === 'RBNode_elm_builtin')) && (_p27._3._4._0.ctor === 'Black')) {
																		break _v36_5;
																	} else {
																		break _v36_6;
																	}
																}
															} else {
																break _v36_6;
															}
														default:
															if (((((_p27._0.ctor === 'BBlack') && (_p27._3._3.ctor === 'RBNode_elm_builtin')) && (_p27._3._3._0.ctor === 'Black')) && (_p27._3._4.ctor === 'RBNode_elm_builtin')) && (_p27._3._4._0.ctor === 'Black')) {
																break _v36_5;
															} else {
																break _v36_6;
															}
													}
												default:
													switch (_p27._4._0.ctor) {
														case 'Red':
															if ((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Red')) {
																break _v36_2;
															} else {
																if ((_p27._4._4.ctor === 'RBNode_elm_builtin') && (_p27._4._4._0.ctor === 'Red')) {
																	break _v36_3;
																} else {
																	break _v36_6;
																}
															}
														case 'NBlack':
															if (((((_p27._0.ctor === 'BBlack') && (_p27._4._3.ctor === 'RBNode_elm_builtin')) && (_p27._4._3._0.ctor === 'Black')) && (_p27._4._4.ctor === 'RBNode_elm_builtin')) && (_p27._4._4._0.ctor === 'Black')) {
																break _v36_4;
															} else {
																break _v36_6;
															}
														default:
															break _v36_6;
													}
											}
										} else {
											switch (_p27._3._0.ctor) {
												case 'Red':
													if ((_p27._3._3.ctor === 'RBNode_elm_builtin') && (_p27._3._3._0.ctor === 'Red')) {
														break _v36_0;
													} else {
														if ((_p27._3._4.ctor === 'RBNode_elm_builtin') && (_p27._3._4._0.ctor === 'Red')) {
															break _v36_1;
														} else {
															break _v36_6;
														}
													}
												case 'NBlack':
													if (((((_p27._0.ctor === 'BBlack') && (_p27._3._3.ctor === 'RBNode_elm_builtin')) && (_p27._3._3._0.ctor === 'Black')) && (_p27._3._4.ctor === 'RBNode_elm_builtin')) && (_p27._3._4._0.ctor === 'Black')) {
														break _v36_5;
													} else {
														break _v36_6;
													}
												default:
													break _v36_6;
											}
										}
									} else {
										if (_p27._4.ctor === 'RBNode_elm_builtin') {
											switch (_p27._4._0.ctor) {
												case 'Red':
													if ((_p27._4._3.ctor === 'RBNode_elm_builtin') && (_p27._4._3._0.ctor === 'Red')) {
														break _v36_2;
													} else {
														if ((_p27._4._4.ctor === 'RBNode_elm_builtin') && (_p27._4._4._0.ctor === 'Red')) {
															break _v36_3;
														} else {
															break _v36_6;
														}
													}
												case 'NBlack':
													if (((((_p27._0.ctor === 'BBlack') && (_p27._4._3.ctor === 'RBNode_elm_builtin')) && (_p27._4._3._0.ctor === 'Black')) && (_p27._4._4.ctor === 'RBNode_elm_builtin')) && (_p27._4._4._0.ctor === 'Black')) {
														break _v36_4;
													} else {
														break _v36_6;
													}
												default:
													break _v36_6;
											}
										} else {
											break _v36_6;
										}
									}
								} else {
									break _v36_6;
								}
							} while(false);
							return _elm_lang$core$Dict$balancedTree(_p27._0)(_p27._3._3._1)(_p27._3._3._2)(_p27._3._1)(_p27._3._2)(_p27._1)(_p27._2)(_p27._3._3._3)(_p27._3._3._4)(_p27._3._4)(_p27._4);
						} while(false);
						return _elm_lang$core$Dict$balancedTree(_p27._0)(_p27._3._1)(_p27._3._2)(_p27._3._4._1)(_p27._3._4._2)(_p27._1)(_p27._2)(_p27._3._3)(_p27._3._4._3)(_p27._3._4._4)(_p27._4);
					} while(false);
					return _elm_lang$core$Dict$balancedTree(_p27._0)(_p27._1)(_p27._2)(_p27._4._3._1)(_p27._4._3._2)(_p27._4._1)(_p27._4._2)(_p27._3)(_p27._4._3._3)(_p27._4._3._4)(_p27._4._4);
				} while(false);
				return _elm_lang$core$Dict$balancedTree(_p27._0)(_p27._1)(_p27._2)(_p27._4._1)(_p27._4._2)(_p27._4._4._1)(_p27._4._4._2)(_p27._3)(_p27._4._3)(_p27._4._4._3)(_p27._4._4._4);
			} while(false);
			return A5(
				_elm_lang$core$Dict$RBNode_elm_builtin,
				_elm_lang$core$Dict$Black,
				_p27._4._3._1,
				_p27._4._3._2,
				A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p27._1, _p27._2, _p27._3, _p27._4._3._3),
				A5(
					_elm_lang$core$Dict$balance,
					_elm_lang$core$Dict$Black,
					_p27._4._1,
					_p27._4._2,
					_p27._4._3._4,
					_elm_lang$core$Dict$redden(_p27._4._4)));
		} while(false);
		return A5(
			_elm_lang$core$Dict$RBNode_elm_builtin,
			_elm_lang$core$Dict$Black,
			_p27._3._4._1,
			_p27._3._4._2,
			A5(
				_elm_lang$core$Dict$balance,
				_elm_lang$core$Dict$Black,
				_p27._3._1,
				_p27._3._2,
				_elm_lang$core$Dict$redden(_p27._3._3),
				_p27._3._4._3),
			A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p27._1, _p27._2, _p27._3._4._4, _p27._4));
	} while(false);
	return tree;
};
var _elm_lang$core$Dict$balance = F5(
	function (c, k, v, l, r) {
		var tree = A5(_elm_lang$core$Dict$RBNode_elm_builtin, c, k, v, l, r);
		return _elm_lang$core$Dict$blackish(tree) ? _elm_lang$core$Dict$balanceHelp(tree) : tree;
	});
var _elm_lang$core$Dict$bubble = F5(
	function (c, k, v, l, r) {
		return (_elm_lang$core$Dict$isBBlack(l) || _elm_lang$core$Dict$isBBlack(r)) ? A5(
			_elm_lang$core$Dict$balance,
			_elm_lang$core$Dict$moreBlack(c),
			k,
			v,
			_elm_lang$core$Dict$lessBlackTree(l),
			_elm_lang$core$Dict$lessBlackTree(r)) : A5(_elm_lang$core$Dict$RBNode_elm_builtin, c, k, v, l, r);
	});
var _elm_lang$core$Dict$removeMax = F5(
	function (c, k, v, l, r) {
		var _p28 = r;
		if (_p28.ctor === 'RBEmpty_elm_builtin') {
			return A3(_elm_lang$core$Dict$rem, c, l, r);
		} else {
			return A5(
				_elm_lang$core$Dict$bubble,
				c,
				k,
				v,
				l,
				A5(_elm_lang$core$Dict$removeMax, _p28._0, _p28._1, _p28._2, _p28._3, _p28._4));
		}
	});
var _elm_lang$core$Dict$rem = F3(
	function (color, left, right) {
		var _p29 = {ctor: '_Tuple2', _0: left, _1: right};
		if (_p29._0.ctor === 'RBEmpty_elm_builtin') {
			if (_p29._1.ctor === 'RBEmpty_elm_builtin') {
				var _p30 = color;
				switch (_p30.ctor) {
					case 'Red':
						return _elm_lang$core$Dict$RBEmpty_elm_builtin(_elm_lang$core$Dict$LBlack);
					case 'Black':
						return _elm_lang$core$Dict$RBEmpty_elm_builtin(_elm_lang$core$Dict$LBBlack);
					default:
						return _elm_lang$core$Native_Debug.crash('cannot have bblack or nblack nodes at this point');
				}
			} else {
				var _p33 = _p29._1._0;
				var _p32 = _p29._0._0;
				var _p31 = {ctor: '_Tuple3', _0: color, _1: _p32, _2: _p33};
				if ((((_p31.ctor === '_Tuple3') && (_p31._0.ctor === 'Black')) && (_p31._1.ctor === 'LBlack')) && (_p31._2.ctor === 'Red')) {
					return A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p29._1._1, _p29._1._2, _p29._1._3, _p29._1._4);
				} else {
					return A4(
						_elm_lang$core$Dict$reportRemBug,
						'Black/LBlack/Red',
						color,
						_elm_lang$core$Basics$toString(_p32),
						_elm_lang$core$Basics$toString(_p33));
				}
			}
		} else {
			if (_p29._1.ctor === 'RBEmpty_elm_builtin') {
				var _p36 = _p29._1._0;
				var _p35 = _p29._0._0;
				var _p34 = {ctor: '_Tuple3', _0: color, _1: _p35, _2: _p36};
				if ((((_p34.ctor === '_Tuple3') && (_p34._0.ctor === 'Black')) && (_p34._1.ctor === 'Red')) && (_p34._2.ctor === 'LBlack')) {
					return A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Black, _p29._0._1, _p29._0._2, _p29._0._3, _p29._0._4);
				} else {
					return A4(
						_elm_lang$core$Dict$reportRemBug,
						'Black/Red/LBlack',
						color,
						_elm_lang$core$Basics$toString(_p35),
						_elm_lang$core$Basics$toString(_p36));
				}
			} else {
				var _p40 = _p29._0._2;
				var _p39 = _p29._0._4;
				var _p38 = _p29._0._1;
				var newLeft = A5(_elm_lang$core$Dict$removeMax, _p29._0._0, _p38, _p40, _p29._0._3, _p39);
				var _p37 = A3(_elm_lang$core$Dict$maxWithDefault, _p38, _p40, _p39);
				var k = _p37._0;
				var v = _p37._1;
				return A5(_elm_lang$core$Dict$bubble, color, k, v, newLeft, right);
			}
		}
	});
var _elm_lang$core$Dict$map = F2(
	function (f, dict) {
		var _p41 = dict;
		if (_p41.ctor === 'RBEmpty_elm_builtin') {
			return _elm_lang$core$Dict$RBEmpty_elm_builtin(_elm_lang$core$Dict$LBlack);
		} else {
			var _p42 = _p41._1;
			return A5(
				_elm_lang$core$Dict$RBNode_elm_builtin,
				_p41._0,
				_p42,
				A2(f, _p42, _p41._2),
				A2(_elm_lang$core$Dict$map, f, _p41._3),
				A2(_elm_lang$core$Dict$map, f, _p41._4));
		}
	});
var _elm_lang$core$Dict$Same = {ctor: 'Same'};
var _elm_lang$core$Dict$Remove = {ctor: 'Remove'};
var _elm_lang$core$Dict$Insert = {ctor: 'Insert'};
var _elm_lang$core$Dict$update = F3(
	function (k, alter, dict) {
		var up = function (dict) {
			var _p43 = dict;
			if (_p43.ctor === 'RBEmpty_elm_builtin') {
				var _p44 = alter(_elm_lang$core$Maybe$Nothing);
				if (_p44.ctor === 'Nothing') {
					return {ctor: '_Tuple2', _0: _elm_lang$core$Dict$Same, _1: _elm_lang$core$Dict$empty};
				} else {
					return {
						ctor: '_Tuple2',
						_0: _elm_lang$core$Dict$Insert,
						_1: A5(_elm_lang$core$Dict$RBNode_elm_builtin, _elm_lang$core$Dict$Red, k, _p44._0, _elm_lang$core$Dict$empty, _elm_lang$core$Dict$empty)
					};
				}
			} else {
				var _p55 = _p43._2;
				var _p54 = _p43._4;
				var _p53 = _p43._3;
				var _p52 = _p43._1;
				var _p51 = _p43._0;
				var _p45 = A2(_elm_lang$core$Basics$compare, k, _p52);
				switch (_p45.ctor) {
					case 'EQ':
						var _p46 = alter(
							_elm_lang$core$Maybe$Just(_p55));
						if (_p46.ctor === 'Nothing') {
							return {
								ctor: '_Tuple2',
								_0: _elm_lang$core$Dict$Remove,
								_1: A3(_elm_lang$core$Dict$rem, _p51, _p53, _p54)
							};
						} else {
							return {
								ctor: '_Tuple2',
								_0: _elm_lang$core$Dict$Same,
								_1: A5(_elm_lang$core$Dict$RBNode_elm_builtin, _p51, _p52, _p46._0, _p53, _p54)
							};
						}
					case 'LT':
						var _p47 = up(_p53);
						var flag = _p47._0;
						var newLeft = _p47._1;
						var _p48 = flag;
						switch (_p48.ctor) {
							case 'Same':
								return {
									ctor: '_Tuple2',
									_0: _elm_lang$core$Dict$Same,
									_1: A5(_elm_lang$core$Dict$RBNode_elm_builtin, _p51, _p52, _p55, newLeft, _p54)
								};
							case 'Insert':
								return {
									ctor: '_Tuple2',
									_0: _elm_lang$core$Dict$Insert,
									_1: A5(_elm_lang$core$Dict$balance, _p51, _p52, _p55, newLeft, _p54)
								};
							default:
								return {
									ctor: '_Tuple2',
									_0: _elm_lang$core$Dict$Remove,
									_1: A5(_elm_lang$core$Dict$bubble, _p51, _p52, _p55, newLeft, _p54)
								};
						}
					default:
						var _p49 = up(_p54);
						var flag = _p49._0;
						var newRight = _p49._1;
						var _p50 = flag;
						switch (_p50.ctor) {
							case 'Same':
								return {
									ctor: '_Tuple2',
									_0: _elm_lang$core$Dict$Same,
									_1: A5(_elm_lang$core$Dict$RBNode_elm_builtin, _p51, _p52, _p55, _p53, newRight)
								};
							case 'Insert':
								return {
									ctor: '_Tuple2',
									_0: _elm_lang$core$Dict$Insert,
									_1: A5(_elm_lang$core$Dict$balance, _p51, _p52, _p55, _p53, newRight)
								};
							default:
								return {
									ctor: '_Tuple2',
									_0: _elm_lang$core$Dict$Remove,
									_1: A5(_elm_lang$core$Dict$bubble, _p51, _p52, _p55, _p53, newRight)
								};
						}
				}
			}
		};
		var _p56 = up(dict);
		var flag = _p56._0;
		var updatedDict = _p56._1;
		var _p57 = flag;
		switch (_p57.ctor) {
			case 'Same':
				return updatedDict;
			case 'Insert':
				return _elm_lang$core$Dict$ensureBlackRoot(updatedDict);
			default:
				return _elm_lang$core$Dict$blacken(updatedDict);
		}
	});
var _elm_lang$core$Dict$insert = F3(
	function (key, value, dict) {
		return A3(
			_elm_lang$core$Dict$update,
			key,
			_elm_lang$core$Basics$always(
				_elm_lang$core$Maybe$Just(value)),
			dict);
	});
var _elm_lang$core$Dict$singleton = F2(
	function (key, value) {
		return A3(_elm_lang$core$Dict$insert, key, value, _elm_lang$core$Dict$empty);
	});
var _elm_lang$core$Dict$union = F2(
	function (t1, t2) {
		return A3(_elm_lang$core$Dict$foldl, _elm_lang$core$Dict$insert, t2, t1);
	});
var _elm_lang$core$Dict$filter = F2(
	function (predicate, dictionary) {
		var add = F3(
			function (key, value, dict) {
				return A2(predicate, key, value) ? A3(_elm_lang$core$Dict$insert, key, value, dict) : dict;
			});
		return A3(_elm_lang$core$Dict$foldl, add, _elm_lang$core$Dict$empty, dictionary);
	});
var _elm_lang$core$Dict$intersect = F2(
	function (t1, t2) {
		return A2(
			_elm_lang$core$Dict$filter,
			F2(
				function (k, _p58) {
					return A2(_elm_lang$core$Dict$member, k, t2);
				}),
			t1);
	});
var _elm_lang$core$Dict$partition = F2(
	function (predicate, dict) {
		var add = F3(
			function (key, value, _p59) {
				var _p60 = _p59;
				var _p62 = _p60._1;
				var _p61 = _p60._0;
				return A2(predicate, key, value) ? {
					ctor: '_Tuple2',
					_0: A3(_elm_lang$core$Dict$insert, key, value, _p61),
					_1: _p62
				} : {
					ctor: '_Tuple2',
					_0: _p61,
					_1: A3(_elm_lang$core$Dict$insert, key, value, _p62)
				};
			});
		return A3(
			_elm_lang$core$Dict$foldl,
			add,
			{ctor: '_Tuple2', _0: _elm_lang$core$Dict$empty, _1: _elm_lang$core$Dict$empty},
			dict);
	});
var _elm_lang$core$Dict$fromList = function (assocs) {
	return A3(
		_elm_lang$core$List$foldl,
		F2(
			function (_p63, dict) {
				var _p64 = _p63;
				return A3(_elm_lang$core$Dict$insert, _p64._0, _p64._1, dict);
			}),
		_elm_lang$core$Dict$empty,
		assocs);
};
var _elm_lang$core$Dict$remove = F2(
	function (key, dict) {
		return A3(
			_elm_lang$core$Dict$update,
			key,
			_elm_lang$core$Basics$always(_elm_lang$core$Maybe$Nothing),
			dict);
	});
var _elm_lang$core$Dict$diff = F2(
	function (t1, t2) {
		return A3(
			_elm_lang$core$Dict$foldl,
			F3(
				function (k, v, t) {
					return A2(_elm_lang$core$Dict$remove, k, t);
				}),
			t1,
			t2);
	});

//import Maybe, Native.Array, Native.List, Native.Utils, Result //

var _elm_lang$core$Native_Json = function() {


// CORE DECODERS

function succeed(msg)
{
	return {
		ctor: '<decoder>',
		tag: 'succeed',
		msg: msg
	};
}

function fail(msg)
{
	return {
		ctor: '<decoder>',
		tag: 'fail',
		msg: msg
	};
}

function decodePrimitive(tag)
{
	return {
		ctor: '<decoder>',
		tag: tag
	};
}

function decodeContainer(tag, decoder)
{
	return {
		ctor: '<decoder>',
		tag: tag,
		decoder: decoder
	};
}

function decodeNull(value)
{
	return {
		ctor: '<decoder>',
		tag: 'null',
		value: value
	};
}

function decodeField(field, decoder)
{
	return {
		ctor: '<decoder>',
		tag: 'field',
		field: field,
		decoder: decoder
	};
}

function decodeIndex(index, decoder)
{
	return {
		ctor: '<decoder>',
		tag: 'index',
		index: index,
		decoder: decoder
	};
}

function decodeKeyValuePairs(decoder)
{
	return {
		ctor: '<decoder>',
		tag: 'key-value',
		decoder: decoder
	};
}

function mapMany(f, decoders)
{
	return {
		ctor: '<decoder>',
		tag: 'map-many',
		func: f,
		decoders: decoders
	};
}

function andThen(callback, decoder)
{
	return {
		ctor: '<decoder>',
		tag: 'andThen',
		decoder: decoder,
		callback: callback
	};
}

function oneOf(decoders)
{
	return {
		ctor: '<decoder>',
		tag: 'oneOf',
		decoders: decoders
	};
}


// DECODING OBJECTS

function map1(f, d1)
{
	return mapMany(f, [d1]);
}

function map2(f, d1, d2)
{
	return mapMany(f, [d1, d2]);
}

function map3(f, d1, d2, d3)
{
	return mapMany(f, [d1, d2, d3]);
}

function map4(f, d1, d2, d3, d4)
{
	return mapMany(f, [d1, d2, d3, d4]);
}

function map5(f, d1, d2, d3, d4, d5)
{
	return mapMany(f, [d1, d2, d3, d4, d5]);
}

function map6(f, d1, d2, d3, d4, d5, d6)
{
	return mapMany(f, [d1, d2, d3, d4, d5, d6]);
}

function map7(f, d1, d2, d3, d4, d5, d6, d7)
{
	return mapMany(f, [d1, d2, d3, d4, d5, d6, d7]);
}

function map8(f, d1, d2, d3, d4, d5, d6, d7, d8)
{
	return mapMany(f, [d1, d2, d3, d4, d5, d6, d7, d8]);
}


// DECODE HELPERS

function ok(value)
{
	return { tag: 'ok', value: value };
}

function badPrimitive(type, value)
{
	return { tag: 'primitive', type: type, value: value };
}

function badIndex(index, nestedProblems)
{
	return { tag: 'index', index: index, rest: nestedProblems };
}

function badField(field, nestedProblems)
{
	return { tag: 'field', field: field, rest: nestedProblems };
}

function badIndex(index, nestedProblems)
{
	return { tag: 'index', index: index, rest: nestedProblems };
}

function badOneOf(problems)
{
	return { tag: 'oneOf', problems: problems };
}

function bad(msg)
{
	return { tag: 'fail', msg: msg };
}

function badToString(problem)
{
	var context = '_';
	while (problem)
	{
		switch (problem.tag)
		{
			case 'primitive':
				return 'Expecting ' + problem.type
					+ (context === '_' ? '' : ' at ' + context)
					+ ' but instead got: ' + jsToString(problem.value);

			case 'index':
				context += '[' + problem.index + ']';
				problem = problem.rest;
				break;

			case 'field':
				context += '.' + problem.field;
				problem = problem.rest;
				break;

			case 'index':
				context += '[' + problem.index + ']';
				problem = problem.rest;
				break;

			case 'oneOf':
				var problems = problem.problems;
				for (var i = 0; i < problems.length; i++)
				{
					problems[i] = badToString(problems[i]);
				}
				return 'I ran into the following problems'
					+ (context === '_' ? '' : ' at ' + context)
					+ ':\n\n' + problems.join('\n');

			case 'fail':
				return 'I ran into a `fail` decoder'
					+ (context === '_' ? '' : ' at ' + context)
					+ ': ' + problem.msg;
		}
	}
}

function jsToString(value)
{
	return value === undefined
		? 'undefined'
		: JSON.stringify(value);
}


// DECODE

function runOnString(decoder, string)
{
	var json;
	try
	{
		json = JSON.parse(string);
	}
	catch (e)
	{
		return _elm_lang$core$Result$Err('Given an invalid JSON: ' + e.message);
	}
	return run(decoder, json);
}

function run(decoder, value)
{
	var result = runHelp(decoder, value);
	return (result.tag === 'ok')
		? _elm_lang$core$Result$Ok(result.value)
		: _elm_lang$core$Result$Err(badToString(result));
}

function runHelp(decoder, value)
{
	switch (decoder.tag)
	{
		case 'bool':
			return (typeof value === 'boolean')
				? ok(value)
				: badPrimitive('a Bool', value);

		case 'int':
			if (typeof value !== 'number') {
				return badPrimitive('an Int', value);
			}

			if (-2147483647 < value && value < 2147483647 && (value | 0) === value) {
				return ok(value);
			}

			if (isFinite(value) && !(value % 1)) {
				return ok(value);
			}

			return badPrimitive('an Int', value);

		case 'float':
			return (typeof value === 'number')
				? ok(value)
				: badPrimitive('a Float', value);

		case 'string':
			return (typeof value === 'string')
				? ok(value)
				: (value instanceof String)
					? ok(value + '')
					: badPrimitive('a String', value);

		case 'null':
			return (value === null)
				? ok(decoder.value)
				: badPrimitive('null', value);

		case 'value':
			return ok(value);

		case 'list':
			if (!(value instanceof Array))
			{
				return badPrimitive('a List', value);
			}

			var list = _elm_lang$core$Native_List.Nil;
			for (var i = value.length; i--; )
			{
				var result = runHelp(decoder.decoder, value[i]);
				if (result.tag !== 'ok')
				{
					return badIndex(i, result)
				}
				list = _elm_lang$core$Native_List.Cons(result.value, list);
			}
			return ok(list);

		case 'array':
			if (!(value instanceof Array))
			{
				return badPrimitive('an Array', value);
			}

			var len = value.length;
			var array = new Array(len);
			for (var i = len; i--; )
			{
				var result = runHelp(decoder.decoder, value[i]);
				if (result.tag !== 'ok')
				{
					return badIndex(i, result);
				}
				array[i] = result.value;
			}
			return ok(_elm_lang$core$Native_Array.fromJSArray(array));

		case 'maybe':
			var result = runHelp(decoder.decoder, value);
			return (result.tag === 'ok')
				? ok(_elm_lang$core$Maybe$Just(result.value))
				: ok(_elm_lang$core$Maybe$Nothing);

		case 'field':
			var field = decoder.field;
			if (typeof value !== 'object' || value === null || !(field in value))
			{
				return badPrimitive('an object with a field named `' + field + '`', value);
			}

			var result = runHelp(decoder.decoder, value[field]);
			return (result.tag === 'ok') ? result : badField(field, result);

		case 'index':
			var index = decoder.index;
			if (!(value instanceof Array))
			{
				return badPrimitive('an array', value);
			}
			if (index >= value.length)
			{
				return badPrimitive('a longer array. Need index ' + index + ' but there are only ' + value.length + ' entries', value);
			}

			var result = runHelp(decoder.decoder, value[index]);
			return (result.tag === 'ok') ? result : badIndex(index, result);

		case 'key-value':
			if (typeof value !== 'object' || value === null || value instanceof Array)
			{
				return badPrimitive('an object', value);
			}

			var keyValuePairs = _elm_lang$core$Native_List.Nil;
			for (var key in value)
			{
				var result = runHelp(decoder.decoder, value[key]);
				if (result.tag !== 'ok')
				{
					return badField(key, result);
				}
				var pair = _elm_lang$core$Native_Utils.Tuple2(key, result.value);
				keyValuePairs = _elm_lang$core$Native_List.Cons(pair, keyValuePairs);
			}
			return ok(keyValuePairs);

		case 'map-many':
			var answer = decoder.func;
			var decoders = decoder.decoders;
			for (var i = 0; i < decoders.length; i++)
			{
				var result = runHelp(decoders[i], value);
				if (result.tag !== 'ok')
				{
					return result;
				}
				answer = answer(result.value);
			}
			return ok(answer);

		case 'andThen':
			var result = runHelp(decoder.decoder, value);
			return (result.tag !== 'ok')
				? result
				: runHelp(decoder.callback(result.value), value);

		case 'oneOf':
			var errors = [];
			var temp = decoder.decoders;
			while (temp.ctor !== '[]')
			{
				var result = runHelp(temp._0, value);

				if (result.tag === 'ok')
				{
					return result;
				}

				errors.push(result);

				temp = temp._1;
			}
			return badOneOf(errors);

		case 'fail':
			return bad(decoder.msg);

		case 'succeed':
			return ok(decoder.msg);
	}
}


// EQUALITY

function equality(a, b)
{
	if (a === b)
	{
		return true;
	}

	if (a.tag !== b.tag)
	{
		return false;
	}

	switch (a.tag)
	{
		case 'succeed':
		case 'fail':
			return a.msg === b.msg;

		case 'bool':
		case 'int':
		case 'float':
		case 'string':
		case 'value':
			return true;

		case 'null':
			return a.value === b.value;

		case 'list':
		case 'array':
		case 'maybe':
		case 'key-value':
			return equality(a.decoder, b.decoder);

		case 'field':
			return a.field === b.field && equality(a.decoder, b.decoder);

		case 'index':
			return a.index === b.index && equality(a.decoder, b.decoder);

		case 'map-many':
			if (a.func !== b.func)
			{
				return false;
			}
			return listEquality(a.decoders, b.decoders);

		case 'andThen':
			return a.callback === b.callback && equality(a.decoder, b.decoder);

		case 'oneOf':
			return listEquality(a.decoders, b.decoders);
	}
}

function listEquality(aDecoders, bDecoders)
{
	var len = aDecoders.length;
	if (len !== bDecoders.length)
	{
		return false;
	}
	for (var i = 0; i < len; i++)
	{
		if (!equality(aDecoders[i], bDecoders[i]))
		{
			return false;
		}
	}
	return true;
}


// ENCODE

function encode(indentLevel, value)
{
	return JSON.stringify(value, null, indentLevel);
}

function identity(value)
{
	return value;
}

function encodeObject(keyValuePairs)
{
	var obj = {};
	while (keyValuePairs.ctor !== '[]')
	{
		var pair = keyValuePairs._0;
		obj[pair._0] = pair._1;
		keyValuePairs = keyValuePairs._1;
	}
	return obj;
}

return {
	encode: F2(encode),
	runOnString: F2(runOnString),
	run: F2(run),

	decodeNull: decodeNull,
	decodePrimitive: decodePrimitive,
	decodeContainer: F2(decodeContainer),

	decodeField: F2(decodeField),
	decodeIndex: F2(decodeIndex),

	map1: F2(map1),
	map2: F3(map2),
	map3: F4(map3),
	map4: F5(map4),
	map5: F6(map5),
	map6: F7(map6),
	map7: F8(map7),
	map8: F9(map8),
	decodeKeyValuePairs: decodeKeyValuePairs,

	andThen: F2(andThen),
	fail: fail,
	succeed: succeed,
	oneOf: oneOf,

	identity: identity,
	encodeNull: null,
	encodeArray: _elm_lang$core$Native_Array.toJSArray,
	encodeList: _elm_lang$core$Native_List.toArray,
	encodeObject: encodeObject,

	equality: equality
};

}();

var _elm_lang$core$Json_Encode$list = _elm_lang$core$Native_Json.encodeList;
var _elm_lang$core$Json_Encode$array = _elm_lang$core$Native_Json.encodeArray;
var _elm_lang$core$Json_Encode$object = _elm_lang$core$Native_Json.encodeObject;
var _elm_lang$core$Json_Encode$null = _elm_lang$core$Native_Json.encodeNull;
var _elm_lang$core$Json_Encode$bool = _elm_lang$core$Native_Json.identity;
var _elm_lang$core$Json_Encode$float = _elm_lang$core$Native_Json.identity;
var _elm_lang$core$Json_Encode$int = _elm_lang$core$Native_Json.identity;
var _elm_lang$core$Json_Encode$string = _elm_lang$core$Native_Json.identity;
var _elm_lang$core$Json_Encode$encode = _elm_lang$core$Native_Json.encode;
var _elm_lang$core$Json_Encode$Value = {ctor: 'Value'};

var _elm_lang$core$Json_Decode$null = _elm_lang$core$Native_Json.decodeNull;
var _elm_lang$core$Json_Decode$value = _elm_lang$core$Native_Json.decodePrimitive('value');
var _elm_lang$core$Json_Decode$andThen = _elm_lang$core$Native_Json.andThen;
var _elm_lang$core$Json_Decode$fail = _elm_lang$core$Native_Json.fail;
var _elm_lang$core$Json_Decode$succeed = _elm_lang$core$Native_Json.succeed;
var _elm_lang$core$Json_Decode$lazy = function (thunk) {
	return A2(
		_elm_lang$core$Json_Decode$andThen,
		thunk,
		_elm_lang$core$Json_Decode$succeed(
			{ctor: '_Tuple0'}));
};
var _elm_lang$core$Json_Decode$decodeValue = _elm_lang$core$Native_Json.run;
var _elm_lang$core$Json_Decode$decodeString = _elm_lang$core$Native_Json.runOnString;
var _elm_lang$core$Json_Decode$map8 = _elm_lang$core$Native_Json.map8;
var _elm_lang$core$Json_Decode$map7 = _elm_lang$core$Native_Json.map7;
var _elm_lang$core$Json_Decode$map6 = _elm_lang$core$Native_Json.map6;
var _elm_lang$core$Json_Decode$map5 = _elm_lang$core$Native_Json.map5;
var _elm_lang$core$Json_Decode$map4 = _elm_lang$core$Native_Json.map4;
var _elm_lang$core$Json_Decode$map3 = _elm_lang$core$Native_Json.map3;
var _elm_lang$core$Json_Decode$map2 = _elm_lang$core$Native_Json.map2;
var _elm_lang$core$Json_Decode$map = _elm_lang$core$Native_Json.map1;
var _elm_lang$core$Json_Decode$oneOf = _elm_lang$core$Native_Json.oneOf;
var _elm_lang$core$Json_Decode$maybe = function (decoder) {
	return A2(_elm_lang$core$Native_Json.decodeContainer, 'maybe', decoder);
};
var _elm_lang$core$Json_Decode$index = _elm_lang$core$Native_Json.decodeIndex;
var _elm_lang$core$Json_Decode$field = _elm_lang$core$Native_Json.decodeField;
var _elm_lang$core$Json_Decode$at = F2(
	function (fields, decoder) {
		return A3(_elm_lang$core$List$foldr, _elm_lang$core$Json_Decode$field, decoder, fields);
	});
var _elm_lang$core$Json_Decode$keyValuePairs = _elm_lang$core$Native_Json.decodeKeyValuePairs;
var _elm_lang$core$Json_Decode$dict = function (decoder) {
	return A2(
		_elm_lang$core$Json_Decode$map,
		_elm_lang$core$Dict$fromList,
		_elm_lang$core$Json_Decode$keyValuePairs(decoder));
};
var _elm_lang$core$Json_Decode$array = function (decoder) {
	return A2(_elm_lang$core$Native_Json.decodeContainer, 'array', decoder);
};
var _elm_lang$core$Json_Decode$list = function (decoder) {
	return A2(_elm_lang$core$Native_Json.decodeContainer, 'list', decoder);
};
var _elm_lang$core$Json_Decode$nullable = function (decoder) {
	return _elm_lang$core$Json_Decode$oneOf(
		{
			ctor: '::',
			_0: _elm_lang$core$Json_Decode$null(_elm_lang$core$Maybe$Nothing),
			_1: {
				ctor: '::',
				_0: A2(_elm_lang$core$Json_Decode$map, _elm_lang$core$Maybe$Just, decoder),
				_1: {ctor: '[]'}
			}
		});
};
var _elm_lang$core$Json_Decode$float = _elm_lang$core$Native_Json.decodePrimitive('float');
var _elm_lang$core$Json_Decode$int = _elm_lang$core$Native_Json.decodePrimitive('int');
var _elm_lang$core$Json_Decode$bool = _elm_lang$core$Native_Json.decodePrimitive('bool');
var _elm_lang$core$Json_Decode$string = _elm_lang$core$Native_Json.decodePrimitive('string');
var _elm_lang$core$Json_Decode$Decoder = {ctor: 'Decoder'};

var _elm_lang$core$Debug$crash = _elm_lang$core$Native_Debug.crash;
var _elm_lang$core$Debug$log = _elm_lang$core$Native_Debug.log;

var _elm_lang$core$Tuple$mapSecond = F2(
	function (func, _p0) {
		var _p1 = _p0;
		return {
			ctor: '_Tuple2',
			_0: _p1._0,
			_1: func(_p1._1)
		};
	});
var _elm_lang$core$Tuple$mapFirst = F2(
	function (func, _p2) {
		var _p3 = _p2;
		return {
			ctor: '_Tuple2',
			_0: func(_p3._0),
			_1: _p3._1
		};
	});
var _elm_lang$core$Tuple$second = function (_p4) {
	var _p5 = _p4;
	return _p5._1;
};
var _elm_lang$core$Tuple$first = function (_p6) {
	var _p7 = _p6;
	return _p7._0;
};

//import //

var _elm_lang$core$Native_Platform = function() {


// PROGRAMS

function program(impl)
{
	return function(flagDecoder)
	{
		return function(object, moduleName)
		{
			object['worker'] = function worker(flags)
			{
				if (typeof flags !== 'undefined')
				{
					throw new Error(
						'The `' + moduleName + '` module does not need flags.\n'
						+ 'Call ' + moduleName + '.worker() with no arguments and you should be all set!'
					);
				}

				return initialize(
					impl.init,
					impl.update,
					impl.subscriptions,
					renderer
				);
			};
		};
	};
}

function programWithFlags(impl)
{
	return function(flagDecoder)
	{
		return function(object, moduleName)
		{
			object['worker'] = function worker(flags)
			{
				if (typeof flagDecoder === 'undefined')
				{
					throw new Error(
						'Are you trying to sneak a Never value into Elm? Trickster!\n'
						+ 'It looks like ' + moduleName + '.main is defined with `programWithFlags` but has type `Program Never`.\n'
						+ 'Use `program` instead if you do not want flags.'
					);
				}

				var result = A2(_elm_lang$core$Native_Json.run, flagDecoder, flags);
				if (result.ctor === 'Err')
				{
					throw new Error(
						moduleName + '.worker(...) was called with an unexpected argument.\n'
						+ 'I tried to convert it to an Elm value, but ran into this problem:\n\n'
						+ result._0
					);
				}

				return initialize(
					impl.init(result._0),
					impl.update,
					impl.subscriptions,
					renderer
				);
			};
		};
	};
}

function renderer(enqueue, _)
{
	return function(_) {};
}


// HTML TO PROGRAM

function htmlToProgram(vnode)
{
	var emptyBag = batch(_elm_lang$core$Native_List.Nil);
	var noChange = _elm_lang$core$Native_Utils.Tuple2(
		_elm_lang$core$Native_Utils.Tuple0,
		emptyBag
	);

	return _elm_lang$virtual_dom$VirtualDom$program({
		init: noChange,
		view: function(model) { return main; },
		update: F2(function(msg, model) { return noChange; }),
		subscriptions: function (model) { return emptyBag; }
	});
}


// INITIALIZE A PROGRAM

function initialize(init, update, subscriptions, renderer)
{
	// ambient state
	var managers = {};
	var updateView;

	// init and update state in main process
	var initApp = _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
		var model = init._0;
		updateView = renderer(enqueue, model);
		var cmds = init._1;
		var subs = subscriptions(model);
		dispatchEffects(managers, cmds, subs);
		callback(_elm_lang$core$Native_Scheduler.succeed(model));
	});

	function onMessage(msg, model)
	{
		return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
			var results = A2(update, msg, model);
			model = results._0;
			updateView(model);
			var cmds = results._1;
			var subs = subscriptions(model);
			dispatchEffects(managers, cmds, subs);
			callback(_elm_lang$core$Native_Scheduler.succeed(model));
		});
	}

	var mainProcess = spawnLoop(initApp, onMessage);

	function enqueue(msg)
	{
		_elm_lang$core$Native_Scheduler.rawSend(mainProcess, msg);
	}

	var ports = setupEffects(managers, enqueue);

	return ports ? { ports: ports } : {};
}


// EFFECT MANAGERS

var effectManagers = {};

function setupEffects(managers, callback)
{
	var ports;

	// setup all necessary effect managers
	for (var key in effectManagers)
	{
		var manager = effectManagers[key];

		if (manager.isForeign)
		{
			ports = ports || {};
			ports[key] = manager.tag === 'cmd'
				? setupOutgoingPort(key)
				: setupIncomingPort(key, callback);
		}

		managers[key] = makeManager(manager, callback);
	}

	return ports;
}

function makeManager(info, callback)
{
	var router = {
		main: callback,
		self: undefined
	};

	var tag = info.tag;
	var onEffects = info.onEffects;
	var onSelfMsg = info.onSelfMsg;

	function onMessage(msg, state)
	{
		if (msg.ctor === 'self')
		{
			return A3(onSelfMsg, router, msg._0, state);
		}

		var fx = msg._0;
		switch (tag)
		{
			case 'cmd':
				return A3(onEffects, router, fx.cmds, state);

			case 'sub':
				return A3(onEffects, router, fx.subs, state);

			case 'fx':
				return A4(onEffects, router, fx.cmds, fx.subs, state);
		}
	}

	var process = spawnLoop(info.init, onMessage);
	router.self = process;
	return process;
}

function sendToApp(router, msg)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		router.main(msg);
		callback(_elm_lang$core$Native_Scheduler.succeed(_elm_lang$core$Native_Utils.Tuple0));
	});
}

function sendToSelf(router, msg)
{
	return A2(_elm_lang$core$Native_Scheduler.send, router.self, {
		ctor: 'self',
		_0: msg
	});
}


// HELPER for STATEFUL LOOPS

function spawnLoop(init, onMessage)
{
	var andThen = _elm_lang$core$Native_Scheduler.andThen;

	function loop(state)
	{
		var handleMsg = _elm_lang$core$Native_Scheduler.receive(function(msg) {
			return onMessage(msg, state);
		});
		return A2(andThen, loop, handleMsg);
	}

	var task = A2(andThen, loop, init);

	return _elm_lang$core$Native_Scheduler.rawSpawn(task);
}


// BAGS

function leaf(home)
{
	return function(value)
	{
		return {
			type: 'leaf',
			home: home,
			value: value
		};
	};
}

function batch(list)
{
	return {
		type: 'node',
		branches: list
	};
}

function map(tagger, bag)
{
	return {
		type: 'map',
		tagger: tagger,
		tree: bag
	}
}


// PIPE BAGS INTO EFFECT MANAGERS

function dispatchEffects(managers, cmdBag, subBag)
{
	var effectsDict = {};
	gatherEffects(true, cmdBag, effectsDict, null);
	gatherEffects(false, subBag, effectsDict, null);

	for (var home in managers)
	{
		var fx = home in effectsDict
			? effectsDict[home]
			: {
				cmds: _elm_lang$core$Native_List.Nil,
				subs: _elm_lang$core$Native_List.Nil
			};

		_elm_lang$core$Native_Scheduler.rawSend(managers[home], { ctor: 'fx', _0: fx });
	}
}

function gatherEffects(isCmd, bag, effectsDict, taggers)
{
	switch (bag.type)
	{
		case 'leaf':
			var home = bag.home;
			var effect = toEffect(isCmd, home, taggers, bag.value);
			effectsDict[home] = insert(isCmd, effect, effectsDict[home]);
			return;

		case 'node':
			var list = bag.branches;
			while (list.ctor !== '[]')
			{
				gatherEffects(isCmd, list._0, effectsDict, taggers);
				list = list._1;
			}
			return;

		case 'map':
			gatherEffects(isCmd, bag.tree, effectsDict, {
				tagger: bag.tagger,
				rest: taggers
			});
			return;
	}
}

function toEffect(isCmd, home, taggers, value)
{
	function applyTaggers(x)
	{
		var temp = taggers;
		while (temp)
		{
			x = temp.tagger(x);
			temp = temp.rest;
		}
		return x;
	}

	var map = isCmd
		? effectManagers[home].cmdMap
		: effectManagers[home].subMap;

	return A2(map, applyTaggers, value)
}

function insert(isCmd, newEffect, effects)
{
	effects = effects || {
		cmds: _elm_lang$core$Native_List.Nil,
		subs: _elm_lang$core$Native_List.Nil
	};
	if (isCmd)
	{
		effects.cmds = _elm_lang$core$Native_List.Cons(newEffect, effects.cmds);
		return effects;
	}
	effects.subs = _elm_lang$core$Native_List.Cons(newEffect, effects.subs);
	return effects;
}


// PORTS

function checkPortName(name)
{
	if (name in effectManagers)
	{
		throw new Error('There can only be one port named `' + name + '`, but your program has multiple.');
	}
}


// OUTGOING PORTS

function outgoingPort(name, converter)
{
	checkPortName(name);
	effectManagers[name] = {
		tag: 'cmd',
		cmdMap: outgoingPortMap,
		converter: converter,
		isForeign: true
	};
	return leaf(name);
}

var outgoingPortMap = F2(function cmdMap(tagger, value) {
	return value;
});

function setupOutgoingPort(name)
{
	var subs = [];
	var converter = effectManagers[name].converter;

	// CREATE MANAGER

	var init = _elm_lang$core$Native_Scheduler.succeed(null);

	function onEffects(router, cmdList, state)
	{
		while (cmdList.ctor !== '[]')
		{
			// grab a separate reference to subs in case unsubscribe is called
			var currentSubs = subs;
			var value = converter(cmdList._0);
			for (var i = 0; i < currentSubs.length; i++)
			{
				currentSubs[i](value);
			}
			cmdList = cmdList._1;
		}
		return init;
	}

	effectManagers[name].init = init;
	effectManagers[name].onEffects = F3(onEffects);

	// PUBLIC API

	function subscribe(callback)
	{
		subs.push(callback);
	}

	function unsubscribe(callback)
	{
		// copy subs into a new array in case unsubscribe is called within a
		// subscribed callback
		subs = subs.slice();
		var index = subs.indexOf(callback);
		if (index >= 0)
		{
			subs.splice(index, 1);
		}
	}

	return {
		subscribe: subscribe,
		unsubscribe: unsubscribe
	};
}


// INCOMING PORTS

function incomingPort(name, converter)
{
	checkPortName(name);
	effectManagers[name] = {
		tag: 'sub',
		subMap: incomingPortMap,
		converter: converter,
		isForeign: true
	};
	return leaf(name);
}

var incomingPortMap = F2(function subMap(tagger, finalTagger)
{
	return function(value)
	{
		return tagger(finalTagger(value));
	};
});

function setupIncomingPort(name, callback)
{
	var sentBeforeInit = [];
	var subs = _elm_lang$core$Native_List.Nil;
	var converter = effectManagers[name].converter;
	var currentOnEffects = preInitOnEffects;
	var currentSend = preInitSend;

	// CREATE MANAGER

	var init = _elm_lang$core$Native_Scheduler.succeed(null);

	function preInitOnEffects(router, subList, state)
	{
		var postInitResult = postInitOnEffects(router, subList, state);

		for(var i = 0; i < sentBeforeInit.length; i++)
		{
			postInitSend(sentBeforeInit[i]);
		}

		sentBeforeInit = null; // to release objects held in queue
		currentSend = postInitSend;
		currentOnEffects = postInitOnEffects;
		return postInitResult;
	}

	function postInitOnEffects(router, subList, state)
	{
		subs = subList;
		return init;
	}

	function onEffects(router, subList, state)
	{
		return currentOnEffects(router, subList, state);
	}

	effectManagers[name].init = init;
	effectManagers[name].onEffects = F3(onEffects);

	// PUBLIC API

	function preInitSend(value)
	{
		sentBeforeInit.push(value);
	}

	function postInitSend(incomingValue)
	{
		var result = A2(_elm_lang$core$Json_Decode$decodeValue, converter, incomingValue);
		if (result.ctor === 'Err')
		{
			throw new Error('Trying to send an unexpected type of value through port `' + name + '`:\n' + result._0);
		}

		var value = result._0;
		var temp = subs;
		while (temp.ctor !== '[]')
		{
			callback(temp._0(value));
			temp = temp._1;
		}
	}

	function send(incomingValue)
	{
		currentSend(incomingValue);
	}

	return { send: send };
}

return {
	// routers
	sendToApp: F2(sendToApp),
	sendToSelf: F2(sendToSelf),

	// global setup
	effectManagers: effectManagers,
	outgoingPort: outgoingPort,
	incomingPort: incomingPort,

	htmlToProgram: htmlToProgram,
	program: program,
	programWithFlags: programWithFlags,
	initialize: initialize,

	// effect bags
	leaf: leaf,
	batch: batch,
	map: F2(map)
};

}();

//import Native.Utils //

var _elm_lang$core$Native_Scheduler = function() {

var MAX_STEPS = 10000;


// TASKS

function succeed(value)
{
	return {
		ctor: '_Task_succeed',
		value: value
	};
}

function fail(error)
{
	return {
		ctor: '_Task_fail',
		value: error
	};
}

function nativeBinding(callback)
{
	return {
		ctor: '_Task_nativeBinding',
		callback: callback,
		cancel: null
	};
}

function andThen(callback, task)
{
	return {
		ctor: '_Task_andThen',
		callback: callback,
		task: task
	};
}

function onError(callback, task)
{
	return {
		ctor: '_Task_onError',
		callback: callback,
		task: task
	};
}

function receive(callback)
{
	return {
		ctor: '_Task_receive',
		callback: callback
	};
}


// PROCESSES

function rawSpawn(task)
{
	var process = {
		ctor: '_Process',
		id: _elm_lang$core$Native_Utils.guid(),
		root: task,
		stack: null,
		mailbox: []
	};

	enqueue(process);

	return process;
}

function spawn(task)
{
	return nativeBinding(function(callback) {
		var process = rawSpawn(task);
		callback(succeed(process));
	});
}

function rawSend(process, msg)
{
	process.mailbox.push(msg);
	enqueue(process);
}

function send(process, msg)
{
	return nativeBinding(function(callback) {
		rawSend(process, msg);
		callback(succeed(_elm_lang$core$Native_Utils.Tuple0));
	});
}

function kill(process)
{
	return nativeBinding(function(callback) {
		var root = process.root;
		if (root.ctor === '_Task_nativeBinding' && root.cancel)
		{
			root.cancel();
		}

		process.root = null;

		callback(succeed(_elm_lang$core$Native_Utils.Tuple0));
	});
}

function sleep(time)
{
	return nativeBinding(function(callback) {
		var id = setTimeout(function() {
			callback(succeed(_elm_lang$core$Native_Utils.Tuple0));
		}, time);

		return function() { clearTimeout(id); };
	});
}


// STEP PROCESSES

function step(numSteps, process)
{
	while (numSteps < MAX_STEPS)
	{
		var ctor = process.root.ctor;

		if (ctor === '_Task_succeed')
		{
			while (process.stack && process.stack.ctor === '_Task_onError')
			{
				process.stack = process.stack.rest;
			}
			if (process.stack === null)
			{
				break;
			}
			process.root = process.stack.callback(process.root.value);
			process.stack = process.stack.rest;
			++numSteps;
			continue;
		}

		if (ctor === '_Task_fail')
		{
			while (process.stack && process.stack.ctor === '_Task_andThen')
			{
				process.stack = process.stack.rest;
			}
			if (process.stack === null)
			{
				break;
			}
			process.root = process.stack.callback(process.root.value);
			process.stack = process.stack.rest;
			++numSteps;
			continue;
		}

		if (ctor === '_Task_andThen')
		{
			process.stack = {
				ctor: '_Task_andThen',
				callback: process.root.callback,
				rest: process.stack
			};
			process.root = process.root.task;
			++numSteps;
			continue;
		}

		if (ctor === '_Task_onError')
		{
			process.stack = {
				ctor: '_Task_onError',
				callback: process.root.callback,
				rest: process.stack
			};
			process.root = process.root.task;
			++numSteps;
			continue;
		}

		if (ctor === '_Task_nativeBinding')
		{
			process.root.cancel = process.root.callback(function(newRoot) {
				process.root = newRoot;
				enqueue(process);
			});

			break;
		}

		if (ctor === '_Task_receive')
		{
			var mailbox = process.mailbox;
			if (mailbox.length === 0)
			{
				break;
			}

			process.root = process.root.callback(mailbox.shift());
			++numSteps;
			continue;
		}

		throw new Error(ctor);
	}

	if (numSteps < MAX_STEPS)
	{
		return numSteps + 1;
	}
	enqueue(process);

	return numSteps;
}


// WORK QUEUE

var working = false;
var workQueue = [];

function enqueue(process)
{
	workQueue.push(process);

	if (!working)
	{
		setTimeout(work, 0);
		working = true;
	}
}

function work()
{
	var numSteps = 0;
	var process;
	while (numSteps < MAX_STEPS && (process = workQueue.shift()))
	{
		if (process.root)
		{
			numSteps = step(numSteps, process);
		}
	}
	if (!process)
	{
		working = false;
		return;
	}
	setTimeout(work, 0);
}


return {
	succeed: succeed,
	fail: fail,
	nativeBinding: nativeBinding,
	andThen: F2(andThen),
	onError: F2(onError),
	receive: receive,

	spawn: spawn,
	kill: kill,
	sleep: sleep,
	send: F2(send),

	rawSpawn: rawSpawn,
	rawSend: rawSend
};

}();
var _elm_lang$core$Platform_Cmd$batch = _elm_lang$core$Native_Platform.batch;
var _elm_lang$core$Platform_Cmd$none = _elm_lang$core$Platform_Cmd$batch(
	{ctor: '[]'});
var _elm_lang$core$Platform_Cmd_ops = _elm_lang$core$Platform_Cmd_ops || {};
_elm_lang$core$Platform_Cmd_ops['!'] = F2(
	function (model, commands) {
		return {
			ctor: '_Tuple2',
			_0: model,
			_1: _elm_lang$core$Platform_Cmd$batch(commands)
		};
	});
var _elm_lang$core$Platform_Cmd$map = _elm_lang$core$Native_Platform.map;
var _elm_lang$core$Platform_Cmd$Cmd = {ctor: 'Cmd'};

var _elm_lang$core$Platform_Sub$batch = _elm_lang$core$Native_Platform.batch;
var _elm_lang$core$Platform_Sub$none = _elm_lang$core$Platform_Sub$batch(
	{ctor: '[]'});
var _elm_lang$core$Platform_Sub$map = _elm_lang$core$Native_Platform.map;
var _elm_lang$core$Platform_Sub$Sub = {ctor: 'Sub'};

var _elm_lang$core$Platform$hack = _elm_lang$core$Native_Scheduler.succeed;
var _elm_lang$core$Platform$sendToSelf = _elm_lang$core$Native_Platform.sendToSelf;
var _elm_lang$core$Platform$sendToApp = _elm_lang$core$Native_Platform.sendToApp;
var _elm_lang$core$Platform$programWithFlags = _elm_lang$core$Native_Platform.programWithFlags;
var _elm_lang$core$Platform$program = _elm_lang$core$Native_Platform.program;
var _elm_lang$core$Platform$Program = {ctor: 'Program'};
var _elm_lang$core$Platform$Task = {ctor: 'Task'};
var _elm_lang$core$Platform$ProcessId = {ctor: 'ProcessId'};
var _elm_lang$core$Platform$Router = {ctor: 'Router'};

var _debois$elm_dom$DOM$className = A2(
	_elm_lang$core$Json_Decode$at,
	{
		ctor: '::',
		_0: 'className',
		_1: {ctor: '[]'}
	},
	_elm_lang$core$Json_Decode$string);
var _debois$elm_dom$DOM$scrollTop = A2(_elm_lang$core$Json_Decode$field, 'scrollTop', _elm_lang$core$Json_Decode$float);
var _debois$elm_dom$DOM$scrollLeft = A2(_elm_lang$core$Json_Decode$field, 'scrollLeft', _elm_lang$core$Json_Decode$float);
var _debois$elm_dom$DOM$offsetTop = A2(_elm_lang$core$Json_Decode$field, 'offsetTop', _elm_lang$core$Json_Decode$float);
var _debois$elm_dom$DOM$offsetLeft = A2(_elm_lang$core$Json_Decode$field, 'offsetLeft', _elm_lang$core$Json_Decode$float);
var _debois$elm_dom$DOM$offsetHeight = A2(_elm_lang$core$Json_Decode$field, 'offsetHeight', _elm_lang$core$Json_Decode$float);
var _debois$elm_dom$DOM$offsetWidth = A2(_elm_lang$core$Json_Decode$field, 'offsetWidth', _elm_lang$core$Json_Decode$float);
var _debois$elm_dom$DOM$childNodes = function (decoder) {
	var loop = F2(
		function (idx, xs) {
			return A2(
				_elm_lang$core$Json_Decode$andThen,
				function (_p0) {
					return A2(
						_elm_lang$core$Maybe$withDefault,
						_elm_lang$core$Json_Decode$succeed(xs),
						A2(
							_elm_lang$core$Maybe$map,
							function (x) {
								return A2(
									loop,
									idx + 1,
									{ctor: '::', _0: x, _1: xs});
							},
							_p0));
				},
				_elm_lang$core$Json_Decode$maybe(
					A2(
						_elm_lang$core$Json_Decode$field,
						_elm_lang$core$Basics$toString(idx),
						decoder)));
		});
	return A2(
		_elm_lang$core$Json_Decode$map,
		_elm_lang$core$List$reverse,
		A2(
			_elm_lang$core$Json_Decode$field,
			'childNodes',
			A2(
				loop,
				0,
				{ctor: '[]'})));
};
var _debois$elm_dom$DOM$childNode = function (idx) {
	return _elm_lang$core$Json_Decode$at(
		{
			ctor: '::',
			_0: 'childNodes',
			_1: {
				ctor: '::',
				_0: _elm_lang$core$Basics$toString(idx),
				_1: {ctor: '[]'}
			}
		});
};
var _debois$elm_dom$DOM$parentElement = function (decoder) {
	return A2(_elm_lang$core$Json_Decode$field, 'parentElement', decoder);
};
var _debois$elm_dom$DOM$previousSibling = function (decoder) {
	return A2(_elm_lang$core$Json_Decode$field, 'previousSibling', decoder);
};
var _debois$elm_dom$DOM$nextSibling = function (decoder) {
	return A2(_elm_lang$core$Json_Decode$field, 'nextSibling', decoder);
};
var _debois$elm_dom$DOM$offsetParent = F2(
	function (x, decoder) {
		return _elm_lang$core$Json_Decode$oneOf(
			{
				ctor: '::',
				_0: A2(
					_elm_lang$core$Json_Decode$field,
					'offsetParent',
					_elm_lang$core$Json_Decode$null(x)),
				_1: {
					ctor: '::',
					_0: A2(_elm_lang$core$Json_Decode$field, 'offsetParent', decoder),
					_1: {ctor: '[]'}
				}
			});
	});
var _debois$elm_dom$DOM$position = F2(
	function (x, y) {
		return A2(
			_elm_lang$core$Json_Decode$andThen,
			function (_p1) {
				var _p2 = _p1;
				var _p4 = _p2._1;
				var _p3 = _p2._0;
				return A2(
					_debois$elm_dom$DOM$offsetParent,
					{ctor: '_Tuple2', _0: _p3, _1: _p4},
					A2(_debois$elm_dom$DOM$position, _p3, _p4));
			},
			A5(
				_elm_lang$core$Json_Decode$map4,
				F4(
					function (scrollLeft, scrollTop, offsetLeft, offsetTop) {
						return {ctor: '_Tuple2', _0: (x + offsetLeft) - scrollLeft, _1: (y + offsetTop) - scrollTop};
					}),
				_debois$elm_dom$DOM$scrollLeft,
				_debois$elm_dom$DOM$scrollTop,
				_debois$elm_dom$DOM$offsetLeft,
				_debois$elm_dom$DOM$offsetTop));
	});
var _debois$elm_dom$DOM$boundingClientRect = A4(
	_elm_lang$core$Json_Decode$map3,
	F3(
		function (_p5, width, height) {
			var _p6 = _p5;
			return {top: _p6._1, left: _p6._0, width: width, height: height};
		}),
	A2(_debois$elm_dom$DOM$position, 0, 0),
	_debois$elm_dom$DOM$offsetWidth,
	_debois$elm_dom$DOM$offsetHeight);
var _debois$elm_dom$DOM$target = function (decoder) {
	return A2(_elm_lang$core$Json_Decode$field, 'target', decoder);
};
var _debois$elm_dom$DOM$Rectangle = F4(
	function (a, b, c, d) {
		return {top: a, left: b, width: c, height: d};
	});

//import Maybe, Native.List //

var _elm_lang$core$Native_Regex = function() {

function escape(str)
{
	return str.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&');
}
function caseInsensitive(re)
{
	return new RegExp(re.source, 'gi');
}
function regex(raw)
{
	return new RegExp(raw, 'g');
}

function contains(re, string)
{
	return string.match(re) !== null;
}

function find(n, re, str)
{
	n = n.ctor === 'All' ? Infinity : n._0;
	var out = [];
	var number = 0;
	var string = str;
	var lastIndex = re.lastIndex;
	var prevLastIndex = -1;
	var result;
	while (number++ < n && (result = re.exec(string)))
	{
		if (prevLastIndex === re.lastIndex) break;
		var i = result.length - 1;
		var subs = new Array(i);
		while (i > 0)
		{
			var submatch = result[i];
			subs[--i] = submatch === undefined
				? _elm_lang$core$Maybe$Nothing
				: _elm_lang$core$Maybe$Just(submatch);
		}
		out.push({
			match: result[0],
			submatches: _elm_lang$core$Native_List.fromArray(subs),
			index: result.index,
			number: number
		});
		prevLastIndex = re.lastIndex;
	}
	re.lastIndex = lastIndex;
	return _elm_lang$core$Native_List.fromArray(out);
}

function replace(n, re, replacer, string)
{
	n = n.ctor === 'All' ? Infinity : n._0;
	var count = 0;
	function jsReplacer(match)
	{
		if (count++ >= n)
		{
			return match;
		}
		var i = arguments.length - 3;
		var submatches = new Array(i);
		while (i > 0)
		{
			var submatch = arguments[i];
			submatches[--i] = submatch === undefined
				? _elm_lang$core$Maybe$Nothing
				: _elm_lang$core$Maybe$Just(submatch);
		}
		return replacer({
			match: match,
			submatches: _elm_lang$core$Native_List.fromArray(submatches),
			index: arguments[arguments.length - 2],
			number: count
		});
	}
	return string.replace(re, jsReplacer);
}

function split(n, re, str)
{
	n = n.ctor === 'All' ? Infinity : n._0;
	if (n === Infinity)
	{
		return _elm_lang$core$Native_List.fromArray(str.split(re));
	}
	var string = str;
	var result;
	var out = [];
	var start = re.lastIndex;
	var restoreLastIndex = re.lastIndex;
	while (n--)
	{
		if (!(result = re.exec(string))) break;
		out.push(string.slice(start, result.index));
		start = re.lastIndex;
	}
	out.push(string.slice(start));
	re.lastIndex = restoreLastIndex;
	return _elm_lang$core$Native_List.fromArray(out);
}

return {
	regex: regex,
	caseInsensitive: caseInsensitive,
	escape: escape,

	contains: F2(contains),
	find: F3(find),
	replace: F4(replace),
	split: F3(split)
};

}();

var _elm_lang$core$Regex$split = _elm_lang$core$Native_Regex.split;
var _elm_lang$core$Regex$replace = _elm_lang$core$Native_Regex.replace;
var _elm_lang$core$Regex$find = _elm_lang$core$Native_Regex.find;
var _elm_lang$core$Regex$contains = _elm_lang$core$Native_Regex.contains;
var _elm_lang$core$Regex$caseInsensitive = _elm_lang$core$Native_Regex.caseInsensitive;
var _elm_lang$core$Regex$regex = _elm_lang$core$Native_Regex.regex;
var _elm_lang$core$Regex$escape = _elm_lang$core$Native_Regex.escape;
var _elm_lang$core$Regex$Match = F4(
	function (a, b, c, d) {
		return {match: a, submatches: b, index: c, number: d};
	});
var _elm_lang$core$Regex$Regex = {ctor: 'Regex'};
var _elm_lang$core$Regex$AtMost = function (a) {
	return {ctor: 'AtMost', _0: a};
};
var _elm_lang$core$Regex$All = {ctor: 'All'};

var _elm_lang$virtual_dom$VirtualDom_Debug$wrap;
var _elm_lang$virtual_dom$VirtualDom_Debug$wrapWithFlags;

var _elm_lang$virtual_dom$Native_VirtualDom = function() {

var STYLE_KEY = 'STYLE';
var EVENT_KEY = 'EVENT';
var ATTR_KEY = 'ATTR';
var ATTR_NS_KEY = 'ATTR_NS';

var localDoc = typeof document !== 'undefined' ? document : {};


////////////  VIRTUAL DOM NODES  ////////////


function text(string)
{
	return {
		type: 'text',
		text: string
	};
}


function node(tag)
{
	return F2(function(factList, kidList) {
		return nodeHelp(tag, factList, kidList);
	});
}


function nodeHelp(tag, factList, kidList)
{
	var organized = organizeFacts(factList);
	var namespace = organized.namespace;
	var facts = organized.facts;

	var children = [];
	var descendantsCount = 0;
	while (kidList.ctor !== '[]')
	{
		var kid = kidList._0;
		descendantsCount += (kid.descendantsCount || 0);
		children.push(kid);
		kidList = kidList._1;
	}
	descendantsCount += children.length;

	return {
		type: 'node',
		tag: tag,
		facts: facts,
		children: children,
		namespace: namespace,
		descendantsCount: descendantsCount
	};
}


function keyedNode(tag, factList, kidList)
{
	var organized = organizeFacts(factList);
	var namespace = organized.namespace;
	var facts = organized.facts;

	var children = [];
	var descendantsCount = 0;
	while (kidList.ctor !== '[]')
	{
		var kid = kidList._0;
		descendantsCount += (kid._1.descendantsCount || 0);
		children.push(kid);
		kidList = kidList._1;
	}
	descendantsCount += children.length;

	return {
		type: 'keyed-node',
		tag: tag,
		facts: facts,
		children: children,
		namespace: namespace,
		descendantsCount: descendantsCount
	};
}


function custom(factList, model, impl)
{
	var facts = organizeFacts(factList).facts;

	return {
		type: 'custom',
		facts: facts,
		model: model,
		impl: impl
	};
}


function map(tagger, node)
{
	return {
		type: 'tagger',
		tagger: tagger,
		node: node,
		descendantsCount: 1 + (node.descendantsCount || 0)
	};
}


function thunk(func, args, thunk)
{
	return {
		type: 'thunk',
		func: func,
		args: args,
		thunk: thunk,
		node: undefined
	};
}

function lazy(fn, a)
{
	return thunk(fn, [a], function() {
		return fn(a);
	});
}

function lazy2(fn, a, b)
{
	return thunk(fn, [a,b], function() {
		return A2(fn, a, b);
	});
}

function lazy3(fn, a, b, c)
{
	return thunk(fn, [a,b,c], function() {
		return A3(fn, a, b, c);
	});
}



// FACTS


function organizeFacts(factList)
{
	var namespace, facts = {};

	while (factList.ctor !== '[]')
	{
		var entry = factList._0;
		var key = entry.key;

		if (key === ATTR_KEY || key === ATTR_NS_KEY || key === EVENT_KEY)
		{
			var subFacts = facts[key] || {};
			subFacts[entry.realKey] = entry.value;
			facts[key] = subFacts;
		}
		else if (key === STYLE_KEY)
		{
			var styles = facts[key] || {};
			var styleList = entry.value;
			while (styleList.ctor !== '[]')
			{
				var style = styleList._0;
				styles[style._0] = style._1;
				styleList = styleList._1;
			}
			facts[key] = styles;
		}
		else if (key === 'namespace')
		{
			namespace = entry.value;
		}
		else if (key === 'className')
		{
			var classes = facts[key];
			facts[key] = typeof classes === 'undefined'
				? entry.value
				: classes + ' ' + entry.value;
		}
 		else
		{
			facts[key] = entry.value;
		}
		factList = factList._1;
	}

	return {
		facts: facts,
		namespace: namespace
	};
}



////////////  PROPERTIES AND ATTRIBUTES  ////////////


function style(value)
{
	return {
		key: STYLE_KEY,
		value: value
	};
}


function property(key, value)
{
	return {
		key: key,
		value: value
	};
}


function attribute(key, value)
{
	return {
		key: ATTR_KEY,
		realKey: key,
		value: value
	};
}


function attributeNS(namespace, key, value)
{
	return {
		key: ATTR_NS_KEY,
		realKey: key,
		value: {
			value: value,
			namespace: namespace
		}
	};
}


function on(name, options, decoder)
{
	return {
		key: EVENT_KEY,
		realKey: name,
		value: {
			options: options,
			decoder: decoder
		}
	};
}


function equalEvents(a, b)
{
	if (!a.options === b.options)
	{
		if (a.stopPropagation !== b.stopPropagation || a.preventDefault !== b.preventDefault)
		{
			return false;
		}
	}
	return _elm_lang$core$Native_Json.equality(a.decoder, b.decoder);
}


function mapProperty(func, property)
{
	if (property.key !== EVENT_KEY)
	{
		return property;
	}
	return on(
		property.realKey,
		property.value.options,
		A2(_elm_lang$core$Json_Decode$map, func, property.value.decoder)
	);
}


////////////  RENDER  ////////////


function render(vNode, eventNode)
{
	switch (vNode.type)
	{
		case 'thunk':
			if (!vNode.node)
			{
				vNode.node = vNode.thunk();
			}
			return render(vNode.node, eventNode);

		case 'tagger':
			var subNode = vNode.node;
			var tagger = vNode.tagger;

			while (subNode.type === 'tagger')
			{
				typeof tagger !== 'object'
					? tagger = [tagger, subNode.tagger]
					: tagger.push(subNode.tagger);

				subNode = subNode.node;
			}

			var subEventRoot = { tagger: tagger, parent: eventNode };
			var domNode = render(subNode, subEventRoot);
			domNode.elm_event_node_ref = subEventRoot;
			return domNode;

		case 'text':
			return localDoc.createTextNode(vNode.text);

		case 'node':
			var domNode = vNode.namespace
				? localDoc.createElementNS(vNode.namespace, vNode.tag)
				: localDoc.createElement(vNode.tag);

			applyFacts(domNode, eventNode, vNode.facts);

			var children = vNode.children;

			for (var i = 0; i < children.length; i++)
			{
				domNode.appendChild(render(children[i], eventNode));
			}

			return domNode;

		case 'keyed-node':
			var domNode = vNode.namespace
				? localDoc.createElementNS(vNode.namespace, vNode.tag)
				: localDoc.createElement(vNode.tag);

			applyFacts(domNode, eventNode, vNode.facts);

			var children = vNode.children;

			for (var i = 0; i < children.length; i++)
			{
				domNode.appendChild(render(children[i]._1, eventNode));
			}

			return domNode;

		case 'custom':
			var domNode = vNode.impl.render(vNode.model);
			applyFacts(domNode, eventNode, vNode.facts);
			return domNode;
	}
}



////////////  APPLY FACTS  ////////////


function applyFacts(domNode, eventNode, facts)
{
	for (var key in facts)
	{
		var value = facts[key];

		switch (key)
		{
			case STYLE_KEY:
				applyStyles(domNode, value);
				break;

			case EVENT_KEY:
				applyEvents(domNode, eventNode, value);
				break;

			case ATTR_KEY:
				applyAttrs(domNode, value);
				break;

			case ATTR_NS_KEY:
				applyAttrsNS(domNode, value);
				break;

			case 'value':
				if (domNode[key] !== value)
				{
					domNode[key] = value;
				}
				break;

			default:
				domNode[key] = value;
				break;
		}
	}
}

function applyStyles(domNode, styles)
{
	var domNodeStyle = domNode.style;

	for (var key in styles)
	{
		domNodeStyle[key] = styles[key];
	}
}

function applyEvents(domNode, eventNode, events)
{
	var allHandlers = domNode.elm_handlers || {};

	for (var key in events)
	{
		var handler = allHandlers[key];
		var value = events[key];

		if (typeof value === 'undefined')
		{
			domNode.removeEventListener(key, handler);
			allHandlers[key] = undefined;
		}
		else if (typeof handler === 'undefined')
		{
			var handler = makeEventHandler(eventNode, value);
			domNode.addEventListener(key, handler);
			allHandlers[key] = handler;
		}
		else
		{
			handler.info = value;
		}
	}

	domNode.elm_handlers = allHandlers;
}

function makeEventHandler(eventNode, info)
{
	function eventHandler(event)
	{
		var info = eventHandler.info;

		var value = A2(_elm_lang$core$Native_Json.run, info.decoder, event);

		if (value.ctor === 'Ok')
		{
			var options = info.options;
			if (options.stopPropagation)
			{
				event.stopPropagation();
			}
			if (options.preventDefault)
			{
				event.preventDefault();
			}

			var message = value._0;

			var currentEventNode = eventNode;
			while (currentEventNode)
			{
				var tagger = currentEventNode.tagger;
				if (typeof tagger === 'function')
				{
					message = tagger(message);
				}
				else
				{
					for (var i = tagger.length; i--; )
					{
						message = tagger[i](message);
					}
				}
				currentEventNode = currentEventNode.parent;
			}
		}
	};

	eventHandler.info = info;

	return eventHandler;
}

function applyAttrs(domNode, attrs)
{
	for (var key in attrs)
	{
		var value = attrs[key];
		if (typeof value === 'undefined')
		{
			domNode.removeAttribute(key);
		}
		else
		{
			domNode.setAttribute(key, value);
		}
	}
}

function applyAttrsNS(domNode, nsAttrs)
{
	for (var key in nsAttrs)
	{
		var pair = nsAttrs[key];
		var namespace = pair.namespace;
		var value = pair.value;

		if (typeof value === 'undefined')
		{
			domNode.removeAttributeNS(namespace, key);
		}
		else
		{
			domNode.setAttributeNS(namespace, key, value);
		}
	}
}



////////////  DIFF  ////////////


function diff(a, b)
{
	var patches = [];
	diffHelp(a, b, patches, 0);
	return patches;
}


function makePatch(type, index, data)
{
	return {
		index: index,
		type: type,
		data: data,
		domNode: undefined,
		eventNode: undefined
	};
}


function diffHelp(a, b, patches, index)
{
	if (a === b)
	{
		return;
	}

	var aType = a.type;
	var bType = b.type;

	// Bail if you run into different types of nodes. Implies that the
	// structure has changed significantly and it's not worth a diff.
	if (aType !== bType)
	{
		patches.push(makePatch('p-redraw', index, b));
		return;
	}

	// Now we know that both nodes are the same type.
	switch (bType)
	{
		case 'thunk':
			var aArgs = a.args;
			var bArgs = b.args;
			var i = aArgs.length;
			var same = a.func === b.func && i === bArgs.length;
			while (same && i--)
			{
				same = aArgs[i] === bArgs[i];
			}
			if (same)
			{
				b.node = a.node;
				return;
			}
			b.node = b.thunk();
			var subPatches = [];
			diffHelp(a.node, b.node, subPatches, 0);
			if (subPatches.length > 0)
			{
				patches.push(makePatch('p-thunk', index, subPatches));
			}
			return;

		case 'tagger':
			// gather nested taggers
			var aTaggers = a.tagger;
			var bTaggers = b.tagger;
			var nesting = false;

			var aSubNode = a.node;
			while (aSubNode.type === 'tagger')
			{
				nesting = true;

				typeof aTaggers !== 'object'
					? aTaggers = [aTaggers, aSubNode.tagger]
					: aTaggers.push(aSubNode.tagger);

				aSubNode = aSubNode.node;
			}

			var bSubNode = b.node;
			while (bSubNode.type === 'tagger')
			{
				nesting = true;

				typeof bTaggers !== 'object'
					? bTaggers = [bTaggers, bSubNode.tagger]
					: bTaggers.push(bSubNode.tagger);

				bSubNode = bSubNode.node;
			}

			// Just bail if different numbers of taggers. This implies the
			// structure of the virtual DOM has changed.
			if (nesting && aTaggers.length !== bTaggers.length)
			{
				patches.push(makePatch('p-redraw', index, b));
				return;
			}

			// check if taggers are "the same"
			if (nesting ? !pairwiseRefEqual(aTaggers, bTaggers) : aTaggers !== bTaggers)
			{
				patches.push(makePatch('p-tagger', index, bTaggers));
			}

			// diff everything below the taggers
			diffHelp(aSubNode, bSubNode, patches, index + 1);
			return;

		case 'text':
			if (a.text !== b.text)
			{
				patches.push(makePatch('p-text', index, b.text));
				return;
			}

			return;

		case 'node':
			// Bail if obvious indicators have changed. Implies more serious
			// structural changes such that it's not worth it to diff.
			if (a.tag !== b.tag || a.namespace !== b.namespace)
			{
				patches.push(makePatch('p-redraw', index, b));
				return;
			}

			var factsDiff = diffFacts(a.facts, b.facts);

			if (typeof factsDiff !== 'undefined')
			{
				patches.push(makePatch('p-facts', index, factsDiff));
			}

			diffChildren(a, b, patches, index);
			return;

		case 'keyed-node':
			// Bail if obvious indicators have changed. Implies more serious
			// structural changes such that it's not worth it to diff.
			if (a.tag !== b.tag || a.namespace !== b.namespace)
			{
				patches.push(makePatch('p-redraw', index, b));
				return;
			}

			var factsDiff = diffFacts(a.facts, b.facts);

			if (typeof factsDiff !== 'undefined')
			{
				patches.push(makePatch('p-facts', index, factsDiff));
			}

			diffKeyedChildren(a, b, patches, index);
			return;

		case 'custom':
			if (a.impl !== b.impl)
			{
				patches.push(makePatch('p-redraw', index, b));
				return;
			}

			var factsDiff = diffFacts(a.facts, b.facts);
			if (typeof factsDiff !== 'undefined')
			{
				patches.push(makePatch('p-facts', index, factsDiff));
			}

			var patch = b.impl.diff(a,b);
			if (patch)
			{
				patches.push(makePatch('p-custom', index, patch));
				return;
			}

			return;
	}
}


// assumes the incoming arrays are the same length
function pairwiseRefEqual(as, bs)
{
	for (var i = 0; i < as.length; i++)
	{
		if (as[i] !== bs[i])
		{
			return false;
		}
	}

	return true;
}


// TODO Instead of creating a new diff object, it's possible to just test if
// there *is* a diff. During the actual patch, do the diff again and make the
// modifications directly. This way, there's no new allocations. Worth it?
function diffFacts(a, b, category)
{
	var diff;

	// look for changes and removals
	for (var aKey in a)
	{
		if (aKey === STYLE_KEY || aKey === EVENT_KEY || aKey === ATTR_KEY || aKey === ATTR_NS_KEY)
		{
			var subDiff = diffFacts(a[aKey], b[aKey] || {}, aKey);
			if (subDiff)
			{
				diff = diff || {};
				diff[aKey] = subDiff;
			}
			continue;
		}

		// remove if not in the new facts
		if (!(aKey in b))
		{
			diff = diff || {};
			diff[aKey] =
				(typeof category === 'undefined')
					? (typeof a[aKey] === 'string' ? '' : null)
					:
				(category === STYLE_KEY)
					? ''
					:
				(category === EVENT_KEY || category === ATTR_KEY)
					? undefined
					:
				{ namespace: a[aKey].namespace, value: undefined };

			continue;
		}

		var aValue = a[aKey];
		var bValue = b[aKey];

		// reference equal, so don't worry about it
		if (aValue === bValue && aKey !== 'value'
			|| category === EVENT_KEY && equalEvents(aValue, bValue))
		{
			continue;
		}

		diff = diff || {};
		diff[aKey] = bValue;
	}

	// add new stuff
	for (var bKey in b)
	{
		if (!(bKey in a))
		{
			diff = diff || {};
			diff[bKey] = b[bKey];
		}
	}

	return diff;
}


function diffChildren(aParent, bParent, patches, rootIndex)
{
	var aChildren = aParent.children;
	var bChildren = bParent.children;

	var aLen = aChildren.length;
	var bLen = bChildren.length;

	// FIGURE OUT IF THERE ARE INSERTS OR REMOVALS

	if (aLen > bLen)
	{
		patches.push(makePatch('p-remove-last', rootIndex, aLen - bLen));
	}
	else if (aLen < bLen)
	{
		patches.push(makePatch('p-append', rootIndex, bChildren.slice(aLen)));
	}

	// PAIRWISE DIFF EVERYTHING ELSE

	var index = rootIndex;
	var minLen = aLen < bLen ? aLen : bLen;
	for (var i = 0; i < minLen; i++)
	{
		index++;
		var aChild = aChildren[i];
		diffHelp(aChild, bChildren[i], patches, index);
		index += aChild.descendantsCount || 0;
	}
}



////////////  KEYED DIFF  ////////////


function diffKeyedChildren(aParent, bParent, patches, rootIndex)
{
	var localPatches = [];

	var changes = {}; // Dict String Entry
	var inserts = []; // Array { index : Int, entry : Entry }
	// type Entry = { tag : String, vnode : VNode, index : Int, data : _ }

	var aChildren = aParent.children;
	var bChildren = bParent.children;
	var aLen = aChildren.length;
	var bLen = bChildren.length;
	var aIndex = 0;
	var bIndex = 0;

	var index = rootIndex;

	while (aIndex < aLen && bIndex < bLen)
	{
		var a = aChildren[aIndex];
		var b = bChildren[bIndex];

		var aKey = a._0;
		var bKey = b._0;
		var aNode = a._1;
		var bNode = b._1;

		// check if keys match

		if (aKey === bKey)
		{
			index++;
			diffHelp(aNode, bNode, localPatches, index);
			index += aNode.descendantsCount || 0;

			aIndex++;
			bIndex++;
			continue;
		}

		// look ahead 1 to detect insertions and removals.

		var aLookAhead = aIndex + 1 < aLen;
		var bLookAhead = bIndex + 1 < bLen;

		if (aLookAhead)
		{
			var aNext = aChildren[aIndex + 1];
			var aNextKey = aNext._0;
			var aNextNode = aNext._1;
			var oldMatch = bKey === aNextKey;
		}

		if (bLookAhead)
		{
			var bNext = bChildren[bIndex + 1];
			var bNextKey = bNext._0;
			var bNextNode = bNext._1;
			var newMatch = aKey === bNextKey;
		}


		// swap a and b
		if (aLookAhead && bLookAhead && newMatch && oldMatch)
		{
			index++;
			diffHelp(aNode, bNextNode, localPatches, index);
			insertNode(changes, localPatches, aKey, bNode, bIndex, inserts);
			index += aNode.descendantsCount || 0;

			index++;
			removeNode(changes, localPatches, aKey, aNextNode, index);
			index += aNextNode.descendantsCount || 0;

			aIndex += 2;
			bIndex += 2;
			continue;
		}

		// insert b
		if (bLookAhead && newMatch)
		{
			index++;
			insertNode(changes, localPatches, bKey, bNode, bIndex, inserts);
			diffHelp(aNode, bNextNode, localPatches, index);
			index += aNode.descendantsCount || 0;

			aIndex += 1;
			bIndex += 2;
			continue;
		}

		// remove a
		if (aLookAhead && oldMatch)
		{
			index++;
			removeNode(changes, localPatches, aKey, aNode, index);
			index += aNode.descendantsCount || 0;

			index++;
			diffHelp(aNextNode, bNode, localPatches, index);
			index += aNextNode.descendantsCount || 0;

			aIndex += 2;
			bIndex += 1;
			continue;
		}

		// remove a, insert b
		if (aLookAhead && bLookAhead && aNextKey === bNextKey)
		{
			index++;
			removeNode(changes, localPatches, aKey, aNode, index);
			insertNode(changes, localPatches, bKey, bNode, bIndex, inserts);
			index += aNode.descendantsCount || 0;

			index++;
			diffHelp(aNextNode, bNextNode, localPatches, index);
			index += aNextNode.descendantsCount || 0;

			aIndex += 2;
			bIndex += 2;
			continue;
		}

		break;
	}

	// eat up any remaining nodes with removeNode and insertNode

	while (aIndex < aLen)
	{
		index++;
		var a = aChildren[aIndex];
		var aNode = a._1;
		removeNode(changes, localPatches, a._0, aNode, index);
		index += aNode.descendantsCount || 0;
		aIndex++;
	}

	var endInserts;
	while (bIndex < bLen)
	{
		endInserts = endInserts || [];
		var b = bChildren[bIndex];
		insertNode(changes, localPatches, b._0, b._1, undefined, endInserts);
		bIndex++;
	}

	if (localPatches.length > 0 || inserts.length > 0 || typeof endInserts !== 'undefined')
	{
		patches.push(makePatch('p-reorder', rootIndex, {
			patches: localPatches,
			inserts: inserts,
			endInserts: endInserts
		}));
	}
}



////////////  CHANGES FROM KEYED DIFF  ////////////


var POSTFIX = '_elmW6BL';


function insertNode(changes, localPatches, key, vnode, bIndex, inserts)
{
	var entry = changes[key];

	// never seen this key before
	if (typeof entry === 'undefined')
	{
		entry = {
			tag: 'insert',
			vnode: vnode,
			index: bIndex,
			data: undefined
		};

		inserts.push({ index: bIndex, entry: entry });
		changes[key] = entry;

		return;
	}

	// this key was removed earlier, a match!
	if (entry.tag === 'remove')
	{
		inserts.push({ index: bIndex, entry: entry });

		entry.tag = 'move';
		var subPatches = [];
		diffHelp(entry.vnode, vnode, subPatches, entry.index);
		entry.index = bIndex;
		entry.data.data = {
			patches: subPatches,
			entry: entry
		};

		return;
	}

	// this key has already been inserted or moved, a duplicate!
	insertNode(changes, localPatches, key + POSTFIX, vnode, bIndex, inserts);
}


function removeNode(changes, localPatches, key, vnode, index)
{
	var entry = changes[key];

	// never seen this key before
	if (typeof entry === 'undefined')
	{
		var patch = makePatch('p-remove', index, undefined);
		localPatches.push(patch);

		changes[key] = {
			tag: 'remove',
			vnode: vnode,
			index: index,
			data: patch
		};

		return;
	}

	// this key was inserted earlier, a match!
	if (entry.tag === 'insert')
	{
		entry.tag = 'move';
		var subPatches = [];
		diffHelp(vnode, entry.vnode, subPatches, index);

		var patch = makePatch('p-remove', index, {
			patches: subPatches,
			entry: entry
		});
		localPatches.push(patch);

		return;
	}

	// this key has already been removed or moved, a duplicate!
	removeNode(changes, localPatches, key + POSTFIX, vnode, index);
}



////////////  ADD DOM NODES  ////////////
//
// Each DOM node has an "index" assigned in order of traversal. It is important
// to minimize our crawl over the actual DOM, so these indexes (along with the
// descendantsCount of virtual nodes) let us skip touching entire subtrees of
// the DOM if we know there are no patches there.


function addDomNodes(domNode, vNode, patches, eventNode)
{
	addDomNodesHelp(domNode, vNode, patches, 0, 0, vNode.descendantsCount, eventNode);
}


// assumes `patches` is non-empty and indexes increase monotonically.
function addDomNodesHelp(domNode, vNode, patches, i, low, high, eventNode)
{
	var patch = patches[i];
	var index = patch.index;

	while (index === low)
	{
		var patchType = patch.type;

		if (patchType === 'p-thunk')
		{
			addDomNodes(domNode, vNode.node, patch.data, eventNode);
		}
		else if (patchType === 'p-reorder')
		{
			patch.domNode = domNode;
			patch.eventNode = eventNode;

			var subPatches = patch.data.patches;
			if (subPatches.length > 0)
			{
				addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
			}
		}
		else if (patchType === 'p-remove')
		{
			patch.domNode = domNode;
			patch.eventNode = eventNode;

			var data = patch.data;
			if (typeof data !== 'undefined')
			{
				data.entry.data = domNode;
				var subPatches = data.patches;
				if (subPatches.length > 0)
				{
					addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
				}
			}
		}
		else
		{
			patch.domNode = domNode;
			patch.eventNode = eventNode;
		}

		i++;

		if (!(patch = patches[i]) || (index = patch.index) > high)
		{
			return i;
		}
	}

	switch (vNode.type)
	{
		case 'tagger':
			var subNode = vNode.node;

			while (subNode.type === "tagger")
			{
				subNode = subNode.node;
			}

			return addDomNodesHelp(domNode, subNode, patches, i, low + 1, high, domNode.elm_event_node_ref);

		case 'node':
			var vChildren = vNode.children;
			var childNodes = domNode.childNodes;
			for (var j = 0; j < vChildren.length; j++)
			{
				low++;
				var vChild = vChildren[j];
				var nextLow = low + (vChild.descendantsCount || 0);
				if (low <= index && index <= nextLow)
				{
					i = addDomNodesHelp(childNodes[j], vChild, patches, i, low, nextLow, eventNode);
					if (!(patch = patches[i]) || (index = patch.index) > high)
					{
						return i;
					}
				}
				low = nextLow;
			}
			return i;

		case 'keyed-node':
			var vChildren = vNode.children;
			var childNodes = domNode.childNodes;
			for (var j = 0; j < vChildren.length; j++)
			{
				low++;
				var vChild = vChildren[j]._1;
				var nextLow = low + (vChild.descendantsCount || 0);
				if (low <= index && index <= nextLow)
				{
					i = addDomNodesHelp(childNodes[j], vChild, patches, i, low, nextLow, eventNode);
					if (!(patch = patches[i]) || (index = patch.index) > high)
					{
						return i;
					}
				}
				low = nextLow;
			}
			return i;

		case 'text':
		case 'thunk':
			throw new Error('should never traverse `text` or `thunk` nodes like this');
	}
}



////////////  APPLY PATCHES  ////////////


function applyPatches(rootDomNode, oldVirtualNode, patches, eventNode)
{
	if (patches.length === 0)
	{
		return rootDomNode;
	}

	addDomNodes(rootDomNode, oldVirtualNode, patches, eventNode);
	return applyPatchesHelp(rootDomNode, patches);
}

function applyPatchesHelp(rootDomNode, patches)
{
	for (var i = 0; i < patches.length; i++)
	{
		var patch = patches[i];
		var localDomNode = patch.domNode
		var newNode = applyPatch(localDomNode, patch);
		if (localDomNode === rootDomNode)
		{
			rootDomNode = newNode;
		}
	}
	return rootDomNode;
}

function applyPatch(domNode, patch)
{
	switch (patch.type)
	{
		case 'p-redraw':
			return applyPatchRedraw(domNode, patch.data, patch.eventNode);

		case 'p-facts':
			applyFacts(domNode, patch.eventNode, patch.data);
			return domNode;

		case 'p-text':
			domNode.replaceData(0, domNode.length, patch.data);
			return domNode;

		case 'p-thunk':
			return applyPatchesHelp(domNode, patch.data);

		case 'p-tagger':
			if (typeof domNode.elm_event_node_ref !== 'undefined')
			{
				domNode.elm_event_node_ref.tagger = patch.data;
			}
			else
			{
				domNode.elm_event_node_ref = { tagger: patch.data, parent: patch.eventNode };
			}
			return domNode;

		case 'p-remove-last':
			var i = patch.data;
			while (i--)
			{
				domNode.removeChild(domNode.lastChild);
			}
			return domNode;

		case 'p-append':
			var newNodes = patch.data;
			for (var i = 0; i < newNodes.length; i++)
			{
				domNode.appendChild(render(newNodes[i], patch.eventNode));
			}
			return domNode;

		case 'p-remove':
			var data = patch.data;
			if (typeof data === 'undefined')
			{
				domNode.parentNode.removeChild(domNode);
				return domNode;
			}
			var entry = data.entry;
			if (typeof entry.index !== 'undefined')
			{
				domNode.parentNode.removeChild(domNode);
			}
			entry.data = applyPatchesHelp(domNode, data.patches);
			return domNode;

		case 'p-reorder':
			return applyPatchReorder(domNode, patch);

		case 'p-custom':
			var impl = patch.data;
			return impl.applyPatch(domNode, impl.data);

		default:
			throw new Error('Ran into an unknown patch!');
	}
}


function applyPatchRedraw(domNode, vNode, eventNode)
{
	var parentNode = domNode.parentNode;
	var newNode = render(vNode, eventNode);

	if (typeof newNode.elm_event_node_ref === 'undefined')
	{
		newNode.elm_event_node_ref = domNode.elm_event_node_ref;
	}

	if (parentNode && newNode !== domNode)
	{
		parentNode.replaceChild(newNode, domNode);
	}
	return newNode;
}


function applyPatchReorder(domNode, patch)
{
	var data = patch.data;

	// remove end inserts
	var frag = applyPatchReorderEndInsertsHelp(data.endInserts, patch);

	// removals
	domNode = applyPatchesHelp(domNode, data.patches);

	// inserts
	var inserts = data.inserts;
	for (var i = 0; i < inserts.length; i++)
	{
		var insert = inserts[i];
		var entry = insert.entry;
		var node = entry.tag === 'move'
			? entry.data
			: render(entry.vnode, patch.eventNode);
		domNode.insertBefore(node, domNode.childNodes[insert.index]);
	}

	// add end inserts
	if (typeof frag !== 'undefined')
	{
		domNode.appendChild(frag);
	}

	return domNode;
}


function applyPatchReorderEndInsertsHelp(endInserts, patch)
{
	if (typeof endInserts === 'undefined')
	{
		return;
	}

	var frag = localDoc.createDocumentFragment();
	for (var i = 0; i < endInserts.length; i++)
	{
		var insert = endInserts[i];
		var entry = insert.entry;
		frag.appendChild(entry.tag === 'move'
			? entry.data
			: render(entry.vnode, patch.eventNode)
		);
	}
	return frag;
}


// PROGRAMS

var program = makeProgram(checkNoFlags);
var programWithFlags = makeProgram(checkYesFlags);

function makeProgram(flagChecker)
{
	return F2(function(debugWrap, impl)
	{
		return function(flagDecoder)
		{
			return function(object, moduleName, debugMetadata)
			{
				var checker = flagChecker(flagDecoder, moduleName);
				if (typeof debugMetadata === 'undefined')
				{
					normalSetup(impl, object, moduleName, checker);
				}
				else
				{
					debugSetup(A2(debugWrap, debugMetadata, impl), object, moduleName, checker);
				}
			};
		};
	});
}

function staticProgram(vNode)
{
	var nothing = _elm_lang$core$Native_Utils.Tuple2(
		_elm_lang$core$Native_Utils.Tuple0,
		_elm_lang$core$Platform_Cmd$none
	);
	return A2(program, _elm_lang$virtual_dom$VirtualDom_Debug$wrap, {
		init: nothing,
		view: function() { return vNode; },
		update: F2(function() { return nothing; }),
		subscriptions: function() { return _elm_lang$core$Platform_Sub$none; }
	})();
}


// FLAG CHECKERS

function checkNoFlags(flagDecoder, moduleName)
{
	return function(init, flags, domNode)
	{
		if (typeof flags === 'undefined')
		{
			return init;
		}

		var errorMessage =
			'The `' + moduleName + '` module does not need flags.\n'
			+ 'Initialize it with no arguments and you should be all set!';

		crash(errorMessage, domNode);
	};
}

function checkYesFlags(flagDecoder, moduleName)
{
	return function(init, flags, domNode)
	{
		if (typeof flagDecoder === 'undefined')
		{
			var errorMessage =
				'Are you trying to sneak a Never value into Elm? Trickster!\n'
				+ 'It looks like ' + moduleName + '.main is defined with `programWithFlags` but has type `Program Never`.\n'
				+ 'Use `program` instead if you do not want flags.'

			crash(errorMessage, domNode);
		}

		var result = A2(_elm_lang$core$Native_Json.run, flagDecoder, flags);
		if (result.ctor === 'Ok')
		{
			return init(result._0);
		}

		var errorMessage =
			'Trying to initialize the `' + moduleName + '` module with an unexpected flag.\n'
			+ 'I tried to convert it to an Elm value, but ran into this problem:\n\n'
			+ result._0;

		crash(errorMessage, domNode);
	};
}

function crash(errorMessage, domNode)
{
	if (domNode)
	{
		domNode.innerHTML =
			'<div style="padding-left:1em;">'
			+ '<h2 style="font-weight:normal;"><b>Oops!</b> Something went wrong when starting your Elm program.</h2>'
			+ '<pre style="padding-left:1em;">' + errorMessage + '</pre>'
			+ '</div>';
	}

	throw new Error(errorMessage);
}


//  NORMAL SETUP

function normalSetup(impl, object, moduleName, flagChecker)
{
	object['embed'] = function embed(node, flags)
	{
		while (node.lastChild)
		{
			node.removeChild(node.lastChild);
		}

		return _elm_lang$core$Native_Platform.initialize(
			flagChecker(impl.init, flags, node),
			impl.update,
			impl.subscriptions,
			normalRenderer(node, impl.view)
		);
	};

	object['fullscreen'] = function fullscreen(flags)
	{
		return _elm_lang$core$Native_Platform.initialize(
			flagChecker(impl.init, flags, document.body),
			impl.update,
			impl.subscriptions,
			normalRenderer(document.body, impl.view)
		);
	};
}

function normalRenderer(parentNode, view)
{
	return function(tagger, initialModel)
	{
		var eventNode = { tagger: tagger, parent: undefined };
		var initialVirtualNode = view(initialModel);
		var domNode = render(initialVirtualNode, eventNode);
		parentNode.appendChild(domNode);
		return makeStepper(domNode, view, initialVirtualNode, eventNode);
	};
}


// STEPPER

var rAF =
	typeof requestAnimationFrame !== 'undefined'
		? requestAnimationFrame
		: function(callback) { callback(); };

function makeStepper(domNode, view, initialVirtualNode, eventNode)
{
	var state = 'NO_REQUEST';
	var currNode = initialVirtualNode;
	var nextModel;

	function updateIfNeeded()
	{
		switch (state)
		{
			case 'NO_REQUEST':
				throw new Error(
					'Unexpected draw callback.\n' +
					'Please report this to <https://github.com/elm-lang/virtual-dom/issues>.'
				);

			case 'PENDING_REQUEST':
				rAF(updateIfNeeded);
				state = 'EXTRA_REQUEST';

				var nextNode = view(nextModel);
				var patches = diff(currNode, nextNode);
				domNode = applyPatches(domNode, currNode, patches, eventNode);
				currNode = nextNode;

				return;

			case 'EXTRA_REQUEST':
				state = 'NO_REQUEST';
				return;
		}
	}

	return function stepper(model)
	{
		if (state === 'NO_REQUEST')
		{
			rAF(updateIfNeeded);
		}
		state = 'PENDING_REQUEST';
		nextModel = model;
	};
}


// DEBUG SETUP

function debugSetup(impl, object, moduleName, flagChecker)
{
	object['fullscreen'] = function fullscreen(flags)
	{
		var popoutRef = { doc: undefined };
		return _elm_lang$core$Native_Platform.initialize(
			flagChecker(impl.init, flags, document.body),
			impl.update(scrollTask(popoutRef)),
			impl.subscriptions,
			debugRenderer(moduleName, document.body, popoutRef, impl.view, impl.viewIn, impl.viewOut)
		);
	};

	object['embed'] = function fullscreen(node, flags)
	{
		var popoutRef = { doc: undefined };
		return _elm_lang$core$Native_Platform.initialize(
			flagChecker(impl.init, flags, node),
			impl.update(scrollTask(popoutRef)),
			impl.subscriptions,
			debugRenderer(moduleName, node, popoutRef, impl.view, impl.viewIn, impl.viewOut)
		);
	};
}

function scrollTask(popoutRef)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
	{
		var doc = popoutRef.doc;
		if (doc)
		{
			var msgs = doc.getElementsByClassName('debugger-sidebar-messages')[0];
			if (msgs)
			{
				msgs.scrollTop = msgs.scrollHeight;
			}
		}
		callback(_elm_lang$core$Native_Scheduler.succeed(_elm_lang$core$Native_Utils.Tuple0));
	});
}


function debugRenderer(moduleName, parentNode, popoutRef, view, viewIn, viewOut)
{
	return function(tagger, initialModel)
	{
		var appEventNode = { tagger: tagger, parent: undefined };
		var eventNode = { tagger: tagger, parent: undefined };

		// make normal stepper
		var appVirtualNode = view(initialModel);
		var appNode = render(appVirtualNode, appEventNode);
		parentNode.appendChild(appNode);
		var appStepper = makeStepper(appNode, view, appVirtualNode, appEventNode);

		// make overlay stepper
		var overVirtualNode = viewIn(initialModel)._1;
		var overNode = render(overVirtualNode, eventNode);
		parentNode.appendChild(overNode);
		var wrappedViewIn = wrapViewIn(appEventNode, overNode, viewIn);
		var overStepper = makeStepper(overNode, wrappedViewIn, overVirtualNode, eventNode);

		// make debugger stepper
		var debugStepper = makeDebugStepper(initialModel, viewOut, eventNode, parentNode, moduleName, popoutRef);

		return function stepper(model)
		{
			appStepper(model);
			overStepper(model);
			debugStepper(model);
		}
	};
}

function makeDebugStepper(initialModel, view, eventNode, parentNode, moduleName, popoutRef)
{
	var curr;
	var domNode;

	return function stepper(model)
	{
		if (!model.isDebuggerOpen)
		{
			return;
		}

		if (!popoutRef.doc)
		{
			curr = view(model);
			domNode = openDebugWindow(moduleName, popoutRef, curr, eventNode);
			return;
		}

		// switch to document of popout
		localDoc = popoutRef.doc;

		var next = view(model);
		var patches = diff(curr, next);
		domNode = applyPatches(domNode, curr, patches, eventNode);
		curr = next;

		// switch back to normal document
		localDoc = document;
	};
}

function openDebugWindow(moduleName, popoutRef, virtualNode, eventNode)
{
	var w = 900;
	var h = 360;
	var x = screen.width - w;
	var y = screen.height - h;
	var debugWindow = window.open('', '', 'width=' + w + ',height=' + h + ',left=' + x + ',top=' + y);

	// switch to window document
	localDoc = debugWindow.document;

	popoutRef.doc = localDoc;
	localDoc.title = 'Debugger - ' + moduleName;
	localDoc.body.style.margin = '0';
	localDoc.body.style.padding = '0';
	var domNode = render(virtualNode, eventNode);
	localDoc.body.appendChild(domNode);

	localDoc.addEventListener('keydown', function(event) {
		if (event.metaKey && event.which === 82)
		{
			window.location.reload();
		}
		if (event.which === 38)
		{
			eventNode.tagger({ ctor: 'Up' });
			event.preventDefault();
		}
		if (event.which === 40)
		{
			eventNode.tagger({ ctor: 'Down' });
			event.preventDefault();
		}
	});

	function close()
	{
		popoutRef.doc = undefined;
		debugWindow.close();
	}
	window.addEventListener('unload', close);
	debugWindow.addEventListener('unload', function() {
		popoutRef.doc = undefined;
		window.removeEventListener('unload', close);
		eventNode.tagger({ ctor: 'Close' });
	});

	// switch back to the normal document
	localDoc = document;

	return domNode;
}


// BLOCK EVENTS

function wrapViewIn(appEventNode, overlayNode, viewIn)
{
	var ignorer = makeIgnorer(overlayNode);
	var blocking = 'Normal';
	var overflow;

	var normalTagger = appEventNode.tagger;
	var blockTagger = function() {};

	return function(model)
	{
		var tuple = viewIn(model);
		var newBlocking = tuple._0.ctor;
		appEventNode.tagger = newBlocking === 'Normal' ? normalTagger : blockTagger;
		if (blocking !== newBlocking)
		{
			traverse('removeEventListener', ignorer, blocking);
			traverse('addEventListener', ignorer, newBlocking);

			if (blocking === 'Normal')
			{
				overflow = document.body.style.overflow;
				document.body.style.overflow = 'hidden';
			}

			if (newBlocking === 'Normal')
			{
				document.body.style.overflow = overflow;
			}

			blocking = newBlocking;
		}
		return tuple._1;
	}
}

function traverse(verbEventListener, ignorer, blocking)
{
	switch(blocking)
	{
		case 'Normal':
			return;

		case 'Pause':
			return traverseHelp(verbEventListener, ignorer, mostEvents);

		case 'Message':
			return traverseHelp(verbEventListener, ignorer, allEvents);
	}
}

function traverseHelp(verbEventListener, handler, eventNames)
{
	for (var i = 0; i < eventNames.length; i++)
	{
		document.body[verbEventListener](eventNames[i], handler, true);
	}
}

function makeIgnorer(overlayNode)
{
	return function(event)
	{
		if (event.type === 'keydown' && event.metaKey && event.which === 82)
		{
			return;
		}

		var isScroll = event.type === 'scroll' || event.type === 'wheel';

		var node = event.target;
		while (node !== null)
		{
			if (node.className === 'elm-overlay-message-details' && isScroll)
			{
				return;
			}

			if (node === overlayNode && !isScroll)
			{
				return;
			}
			node = node.parentNode;
		}

		event.stopPropagation();
		event.preventDefault();
	}
}

var mostEvents = [
	'click', 'dblclick', 'mousemove',
	'mouseup', 'mousedown', 'mouseenter', 'mouseleave',
	'touchstart', 'touchend', 'touchcancel', 'touchmove',
	'pointerdown', 'pointerup', 'pointerover', 'pointerout',
	'pointerenter', 'pointerleave', 'pointermove', 'pointercancel',
	'dragstart', 'drag', 'dragend', 'dragenter', 'dragover', 'dragleave', 'drop',
	'keyup', 'keydown', 'keypress',
	'input', 'change',
	'focus', 'blur'
];

var allEvents = mostEvents.concat('wheel', 'scroll');


return {
	node: node,
	text: text,
	custom: custom,
	map: F2(map),

	on: F3(on),
	style: style,
	property: F2(property),
	attribute: F2(attribute),
	attributeNS: F3(attributeNS),
	mapProperty: F2(mapProperty),

	lazy: F2(lazy),
	lazy2: F3(lazy2),
	lazy3: F4(lazy3),
	keyedNode: F3(keyedNode),

	program: program,
	programWithFlags: programWithFlags,
	staticProgram: staticProgram
};

}();

var _elm_lang$virtual_dom$VirtualDom$programWithFlags = function (impl) {
	return A2(_elm_lang$virtual_dom$Native_VirtualDom.programWithFlags, _elm_lang$virtual_dom$VirtualDom_Debug$wrapWithFlags, impl);
};
var _elm_lang$virtual_dom$VirtualDom$program = function (impl) {
	return A2(_elm_lang$virtual_dom$Native_VirtualDom.program, _elm_lang$virtual_dom$VirtualDom_Debug$wrap, impl);
};
var _elm_lang$virtual_dom$VirtualDom$keyedNode = _elm_lang$virtual_dom$Native_VirtualDom.keyedNode;
var _elm_lang$virtual_dom$VirtualDom$lazy3 = _elm_lang$virtual_dom$Native_VirtualDom.lazy3;
var _elm_lang$virtual_dom$VirtualDom$lazy2 = _elm_lang$virtual_dom$Native_VirtualDom.lazy2;
var _elm_lang$virtual_dom$VirtualDom$lazy = _elm_lang$virtual_dom$Native_VirtualDom.lazy;
var _elm_lang$virtual_dom$VirtualDom$defaultOptions = {stopPropagation: false, preventDefault: false};
var _elm_lang$virtual_dom$VirtualDom$onWithOptions = _elm_lang$virtual_dom$Native_VirtualDom.on;
var _elm_lang$virtual_dom$VirtualDom$on = F2(
	function (eventName, decoder) {
		return A3(_elm_lang$virtual_dom$VirtualDom$onWithOptions, eventName, _elm_lang$virtual_dom$VirtualDom$defaultOptions, decoder);
	});
var _elm_lang$virtual_dom$VirtualDom$style = _elm_lang$virtual_dom$Native_VirtualDom.style;
var _elm_lang$virtual_dom$VirtualDom$mapProperty = _elm_lang$virtual_dom$Native_VirtualDom.mapProperty;
var _elm_lang$virtual_dom$VirtualDom$attributeNS = _elm_lang$virtual_dom$Native_VirtualDom.attributeNS;
var _elm_lang$virtual_dom$VirtualDom$attribute = _elm_lang$virtual_dom$Native_VirtualDom.attribute;
var _elm_lang$virtual_dom$VirtualDom$property = _elm_lang$virtual_dom$Native_VirtualDom.property;
var _elm_lang$virtual_dom$VirtualDom$map = _elm_lang$virtual_dom$Native_VirtualDom.map;
var _elm_lang$virtual_dom$VirtualDom$text = _elm_lang$virtual_dom$Native_VirtualDom.text;
var _elm_lang$virtual_dom$VirtualDom$node = _elm_lang$virtual_dom$Native_VirtualDom.node;
var _elm_lang$virtual_dom$VirtualDom$Options = F2(
	function (a, b) {
		return {stopPropagation: a, preventDefault: b};
	});
var _elm_lang$virtual_dom$VirtualDom$Node = {ctor: 'Node'};
var _elm_lang$virtual_dom$VirtualDom$Property = {ctor: 'Property'};

var _elm_lang$html$Html$programWithFlags = _elm_lang$virtual_dom$VirtualDom$programWithFlags;
var _elm_lang$html$Html$program = _elm_lang$virtual_dom$VirtualDom$program;
var _elm_lang$html$Html$beginnerProgram = function (_p0) {
	var _p1 = _p0;
	return _elm_lang$html$Html$program(
		{
			init: A2(
				_elm_lang$core$Platform_Cmd_ops['!'],
				_p1.model,
				{ctor: '[]'}),
			update: F2(
				function (msg, model) {
					return A2(
						_elm_lang$core$Platform_Cmd_ops['!'],
						A2(_p1.update, msg, model),
						{ctor: '[]'});
				}),
			view: _p1.view,
			subscriptions: function (_p2) {
				return _elm_lang$core$Platform_Sub$none;
			}
		});
};
var _elm_lang$html$Html$map = _elm_lang$virtual_dom$VirtualDom$map;
var _elm_lang$html$Html$text = _elm_lang$virtual_dom$VirtualDom$text;
var _elm_lang$html$Html$node = _elm_lang$virtual_dom$VirtualDom$node;
var _elm_lang$html$Html$body = _elm_lang$html$Html$node('body');
var _elm_lang$html$Html$section = _elm_lang$html$Html$node('section');
var _elm_lang$html$Html$nav = _elm_lang$html$Html$node('nav');
var _elm_lang$html$Html$article = _elm_lang$html$Html$node('article');
var _elm_lang$html$Html$aside = _elm_lang$html$Html$node('aside');
var _elm_lang$html$Html$h1 = _elm_lang$html$Html$node('h1');
var _elm_lang$html$Html$h2 = _elm_lang$html$Html$node('h2');
var _elm_lang$html$Html$h3 = _elm_lang$html$Html$node('h3');
var _elm_lang$html$Html$h4 = _elm_lang$html$Html$node('h4');
var _elm_lang$html$Html$h5 = _elm_lang$html$Html$node('h5');
var _elm_lang$html$Html$h6 = _elm_lang$html$Html$node('h6');
var _elm_lang$html$Html$header = _elm_lang$html$Html$node('header');
var _elm_lang$html$Html$footer = _elm_lang$html$Html$node('footer');
var _elm_lang$html$Html$address = _elm_lang$html$Html$node('address');
var _elm_lang$html$Html$main_ = _elm_lang$html$Html$node('main');
var _elm_lang$html$Html$p = _elm_lang$html$Html$node('p');
var _elm_lang$html$Html$hr = _elm_lang$html$Html$node('hr');
var _elm_lang$html$Html$pre = _elm_lang$html$Html$node('pre');
var _elm_lang$html$Html$blockquote = _elm_lang$html$Html$node('blockquote');
var _elm_lang$html$Html$ol = _elm_lang$html$Html$node('ol');
var _elm_lang$html$Html$ul = _elm_lang$html$Html$node('ul');
var _elm_lang$html$Html$li = _elm_lang$html$Html$node('li');
var _elm_lang$html$Html$dl = _elm_lang$html$Html$node('dl');
var _elm_lang$html$Html$dt = _elm_lang$html$Html$node('dt');
var _elm_lang$html$Html$dd = _elm_lang$html$Html$node('dd');
var _elm_lang$html$Html$figure = _elm_lang$html$Html$node('figure');
var _elm_lang$html$Html$figcaption = _elm_lang$html$Html$node('figcaption');
var _elm_lang$html$Html$div = _elm_lang$html$Html$node('div');
var _elm_lang$html$Html$a = _elm_lang$html$Html$node('a');
var _elm_lang$html$Html$em = _elm_lang$html$Html$node('em');
var _elm_lang$html$Html$strong = _elm_lang$html$Html$node('strong');
var _elm_lang$html$Html$small = _elm_lang$html$Html$node('small');
var _elm_lang$html$Html$s = _elm_lang$html$Html$node('s');
var _elm_lang$html$Html$cite = _elm_lang$html$Html$node('cite');
var _elm_lang$html$Html$q = _elm_lang$html$Html$node('q');
var _elm_lang$html$Html$dfn = _elm_lang$html$Html$node('dfn');
var _elm_lang$html$Html$abbr = _elm_lang$html$Html$node('abbr');
var _elm_lang$html$Html$time = _elm_lang$html$Html$node('time');
var _elm_lang$html$Html$code = _elm_lang$html$Html$node('code');
var _elm_lang$html$Html$var = _elm_lang$html$Html$node('var');
var _elm_lang$html$Html$samp = _elm_lang$html$Html$node('samp');
var _elm_lang$html$Html$kbd = _elm_lang$html$Html$node('kbd');
var _elm_lang$html$Html$sub = _elm_lang$html$Html$node('sub');
var _elm_lang$html$Html$sup = _elm_lang$html$Html$node('sup');
var _elm_lang$html$Html$i = _elm_lang$html$Html$node('i');
var _elm_lang$html$Html$b = _elm_lang$html$Html$node('b');
var _elm_lang$html$Html$u = _elm_lang$html$Html$node('u');
var _elm_lang$html$Html$mark = _elm_lang$html$Html$node('mark');
var _elm_lang$html$Html$ruby = _elm_lang$html$Html$node('ruby');
var _elm_lang$html$Html$rt = _elm_lang$html$Html$node('rt');
var _elm_lang$html$Html$rp = _elm_lang$html$Html$node('rp');
var _elm_lang$html$Html$bdi = _elm_lang$html$Html$node('bdi');
var _elm_lang$html$Html$bdo = _elm_lang$html$Html$node('bdo');
var _elm_lang$html$Html$span = _elm_lang$html$Html$node('span');
var _elm_lang$html$Html$br = _elm_lang$html$Html$node('br');
var _elm_lang$html$Html$wbr = _elm_lang$html$Html$node('wbr');
var _elm_lang$html$Html$ins = _elm_lang$html$Html$node('ins');
var _elm_lang$html$Html$del = _elm_lang$html$Html$node('del');
var _elm_lang$html$Html$img = _elm_lang$html$Html$node('img');
var _elm_lang$html$Html$iframe = _elm_lang$html$Html$node('iframe');
var _elm_lang$html$Html$embed = _elm_lang$html$Html$node('embed');
var _elm_lang$html$Html$object = _elm_lang$html$Html$node('object');
var _elm_lang$html$Html$param = _elm_lang$html$Html$node('param');
var _elm_lang$html$Html$video = _elm_lang$html$Html$node('video');
var _elm_lang$html$Html$audio = _elm_lang$html$Html$node('audio');
var _elm_lang$html$Html$source = _elm_lang$html$Html$node('source');
var _elm_lang$html$Html$track = _elm_lang$html$Html$node('track');
var _elm_lang$html$Html$canvas = _elm_lang$html$Html$node('canvas');
var _elm_lang$html$Html$math = _elm_lang$html$Html$node('math');
var _elm_lang$html$Html$table = _elm_lang$html$Html$node('table');
var _elm_lang$html$Html$caption = _elm_lang$html$Html$node('caption');
var _elm_lang$html$Html$colgroup = _elm_lang$html$Html$node('colgroup');
var _elm_lang$html$Html$col = _elm_lang$html$Html$node('col');
var _elm_lang$html$Html$tbody = _elm_lang$html$Html$node('tbody');
var _elm_lang$html$Html$thead = _elm_lang$html$Html$node('thead');
var _elm_lang$html$Html$tfoot = _elm_lang$html$Html$node('tfoot');
var _elm_lang$html$Html$tr = _elm_lang$html$Html$node('tr');
var _elm_lang$html$Html$td = _elm_lang$html$Html$node('td');
var _elm_lang$html$Html$th = _elm_lang$html$Html$node('th');
var _elm_lang$html$Html$form = _elm_lang$html$Html$node('form');
var _elm_lang$html$Html$fieldset = _elm_lang$html$Html$node('fieldset');
var _elm_lang$html$Html$legend = _elm_lang$html$Html$node('legend');
var _elm_lang$html$Html$label = _elm_lang$html$Html$node('label');
var _elm_lang$html$Html$input = _elm_lang$html$Html$node('input');
var _elm_lang$html$Html$button = _elm_lang$html$Html$node('button');
var _elm_lang$html$Html$select = _elm_lang$html$Html$node('select');
var _elm_lang$html$Html$datalist = _elm_lang$html$Html$node('datalist');
var _elm_lang$html$Html$optgroup = _elm_lang$html$Html$node('optgroup');
var _elm_lang$html$Html$option = _elm_lang$html$Html$node('option');
var _elm_lang$html$Html$textarea = _elm_lang$html$Html$node('textarea');
var _elm_lang$html$Html$keygen = _elm_lang$html$Html$node('keygen');
var _elm_lang$html$Html$output = _elm_lang$html$Html$node('output');
var _elm_lang$html$Html$progress = _elm_lang$html$Html$node('progress');
var _elm_lang$html$Html$meter = _elm_lang$html$Html$node('meter');
var _elm_lang$html$Html$details = _elm_lang$html$Html$node('details');
var _elm_lang$html$Html$summary = _elm_lang$html$Html$node('summary');
var _elm_lang$html$Html$menuitem = _elm_lang$html$Html$node('menuitem');
var _elm_lang$html$Html$menu = _elm_lang$html$Html$node('menu');

var _elm_lang$html$Html_Attributes$map = _elm_lang$virtual_dom$VirtualDom$mapProperty;
var _elm_lang$html$Html_Attributes$attribute = _elm_lang$virtual_dom$VirtualDom$attribute;
var _elm_lang$html$Html_Attributes$contextmenu = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'contextmenu', value);
};
var _elm_lang$html$Html_Attributes$draggable = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'draggable', value);
};
var _elm_lang$html$Html_Attributes$itemprop = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'itemprop', value);
};
var _elm_lang$html$Html_Attributes$tabindex = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'tabIndex',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$charset = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'charset', value);
};
var _elm_lang$html$Html_Attributes$height = function (value) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'height',
		_elm_lang$core$Basics$toString(value));
};
var _elm_lang$html$Html_Attributes$width = function (value) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'width',
		_elm_lang$core$Basics$toString(value));
};
var _elm_lang$html$Html_Attributes$formaction = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'formAction', value);
};
var _elm_lang$html$Html_Attributes$list = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'list', value);
};
var _elm_lang$html$Html_Attributes$minlength = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'minLength',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$maxlength = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'maxlength',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$size = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'size',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$form = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'form', value);
};
var _elm_lang$html$Html_Attributes$cols = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'cols',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$rows = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'rows',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$challenge = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'challenge', value);
};
var _elm_lang$html$Html_Attributes$media = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'media', value);
};
var _elm_lang$html$Html_Attributes$rel = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'rel', value);
};
var _elm_lang$html$Html_Attributes$datetime = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'datetime', value);
};
var _elm_lang$html$Html_Attributes$pubdate = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'pubdate', value);
};
var _elm_lang$html$Html_Attributes$colspan = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'colspan',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$rowspan = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$attribute,
		'rowspan',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$manifest = function (value) {
	return A2(_elm_lang$html$Html_Attributes$attribute, 'manifest', value);
};
var _elm_lang$html$Html_Attributes$property = _elm_lang$virtual_dom$VirtualDom$property;
var _elm_lang$html$Html_Attributes$stringProperty = F2(
	function (name, string) {
		return A2(
			_elm_lang$html$Html_Attributes$property,
			name,
			_elm_lang$core$Json_Encode$string(string));
	});
var _elm_lang$html$Html_Attributes$class = function (name) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'className', name);
};
var _elm_lang$html$Html_Attributes$id = function (name) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'id', name);
};
var _elm_lang$html$Html_Attributes$title = function (name) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'title', name);
};
var _elm_lang$html$Html_Attributes$accesskey = function ($char) {
	return A2(
		_elm_lang$html$Html_Attributes$stringProperty,
		'accessKey',
		_elm_lang$core$String$fromChar($char));
};
var _elm_lang$html$Html_Attributes$dir = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'dir', value);
};
var _elm_lang$html$Html_Attributes$dropzone = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'dropzone', value);
};
var _elm_lang$html$Html_Attributes$lang = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'lang', value);
};
var _elm_lang$html$Html_Attributes$content = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'content', value);
};
var _elm_lang$html$Html_Attributes$httpEquiv = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'httpEquiv', value);
};
var _elm_lang$html$Html_Attributes$language = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'language', value);
};
var _elm_lang$html$Html_Attributes$src = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'src', value);
};
var _elm_lang$html$Html_Attributes$alt = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'alt', value);
};
var _elm_lang$html$Html_Attributes$preload = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'preload', value);
};
var _elm_lang$html$Html_Attributes$poster = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'poster', value);
};
var _elm_lang$html$Html_Attributes$kind = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'kind', value);
};
var _elm_lang$html$Html_Attributes$srclang = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'srclang', value);
};
var _elm_lang$html$Html_Attributes$sandbox = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'sandbox', value);
};
var _elm_lang$html$Html_Attributes$srcdoc = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'srcdoc', value);
};
var _elm_lang$html$Html_Attributes$type_ = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'type', value);
};
var _elm_lang$html$Html_Attributes$value = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'value', value);
};
var _elm_lang$html$Html_Attributes$defaultValue = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'defaultValue', value);
};
var _elm_lang$html$Html_Attributes$placeholder = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'placeholder', value);
};
var _elm_lang$html$Html_Attributes$accept = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'accept', value);
};
var _elm_lang$html$Html_Attributes$acceptCharset = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'acceptCharset', value);
};
var _elm_lang$html$Html_Attributes$action = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'action', value);
};
var _elm_lang$html$Html_Attributes$autocomplete = function (bool) {
	return A2(
		_elm_lang$html$Html_Attributes$stringProperty,
		'autocomplete',
		bool ? 'on' : 'off');
};
var _elm_lang$html$Html_Attributes$enctype = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'enctype', value);
};
var _elm_lang$html$Html_Attributes$method = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'method', value);
};
var _elm_lang$html$Html_Attributes$name = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'name', value);
};
var _elm_lang$html$Html_Attributes$pattern = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'pattern', value);
};
var _elm_lang$html$Html_Attributes$for = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'htmlFor', value);
};
var _elm_lang$html$Html_Attributes$max = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'max', value);
};
var _elm_lang$html$Html_Attributes$min = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'min', value);
};
var _elm_lang$html$Html_Attributes$step = function (n) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'step', n);
};
var _elm_lang$html$Html_Attributes$wrap = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'wrap', value);
};
var _elm_lang$html$Html_Attributes$usemap = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'useMap', value);
};
var _elm_lang$html$Html_Attributes$shape = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'shape', value);
};
var _elm_lang$html$Html_Attributes$coords = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'coords', value);
};
var _elm_lang$html$Html_Attributes$keytype = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'keytype', value);
};
var _elm_lang$html$Html_Attributes$align = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'align', value);
};
var _elm_lang$html$Html_Attributes$cite = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'cite', value);
};
var _elm_lang$html$Html_Attributes$href = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'href', value);
};
var _elm_lang$html$Html_Attributes$target = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'target', value);
};
var _elm_lang$html$Html_Attributes$downloadAs = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'download', value);
};
var _elm_lang$html$Html_Attributes$hreflang = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'hreflang', value);
};
var _elm_lang$html$Html_Attributes$ping = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'ping', value);
};
var _elm_lang$html$Html_Attributes$start = function (n) {
	return A2(
		_elm_lang$html$Html_Attributes$stringProperty,
		'start',
		_elm_lang$core$Basics$toString(n));
};
var _elm_lang$html$Html_Attributes$headers = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'headers', value);
};
var _elm_lang$html$Html_Attributes$scope = function (value) {
	return A2(_elm_lang$html$Html_Attributes$stringProperty, 'scope', value);
};
var _elm_lang$html$Html_Attributes$boolProperty = F2(
	function (name, bool) {
		return A2(
			_elm_lang$html$Html_Attributes$property,
			name,
			_elm_lang$core$Json_Encode$bool(bool));
	});
var _elm_lang$html$Html_Attributes$hidden = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'hidden', bool);
};
var _elm_lang$html$Html_Attributes$contenteditable = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'contentEditable', bool);
};
var _elm_lang$html$Html_Attributes$spellcheck = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'spellcheck', bool);
};
var _elm_lang$html$Html_Attributes$async = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'async', bool);
};
var _elm_lang$html$Html_Attributes$defer = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'defer', bool);
};
var _elm_lang$html$Html_Attributes$scoped = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'scoped', bool);
};
var _elm_lang$html$Html_Attributes$autoplay = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'autoplay', bool);
};
var _elm_lang$html$Html_Attributes$controls = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'controls', bool);
};
var _elm_lang$html$Html_Attributes$loop = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'loop', bool);
};
var _elm_lang$html$Html_Attributes$default = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'default', bool);
};
var _elm_lang$html$Html_Attributes$seamless = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'seamless', bool);
};
var _elm_lang$html$Html_Attributes$checked = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'checked', bool);
};
var _elm_lang$html$Html_Attributes$selected = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'selected', bool);
};
var _elm_lang$html$Html_Attributes$autofocus = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'autofocus', bool);
};
var _elm_lang$html$Html_Attributes$disabled = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'disabled', bool);
};
var _elm_lang$html$Html_Attributes$multiple = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'multiple', bool);
};
var _elm_lang$html$Html_Attributes$novalidate = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'noValidate', bool);
};
var _elm_lang$html$Html_Attributes$readonly = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'readOnly', bool);
};
var _elm_lang$html$Html_Attributes$required = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'required', bool);
};
var _elm_lang$html$Html_Attributes$ismap = function (value) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'isMap', value);
};
var _elm_lang$html$Html_Attributes$download = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'download', bool);
};
var _elm_lang$html$Html_Attributes$reversed = function (bool) {
	return A2(_elm_lang$html$Html_Attributes$boolProperty, 'reversed', bool);
};
var _elm_lang$html$Html_Attributes$classList = function (list) {
	return _elm_lang$html$Html_Attributes$class(
		A2(
			_elm_lang$core$String$join,
			' ',
			A2(
				_elm_lang$core$List$map,
				_elm_lang$core$Tuple$first,
				A2(_elm_lang$core$List$filter, _elm_lang$core$Tuple$second, list))));
};
var _elm_lang$html$Html_Attributes$style = _elm_lang$virtual_dom$VirtualDom$style;

var _elm_lang$html$Html_Events$keyCode = A2(_elm_lang$core$Json_Decode$field, 'keyCode', _elm_lang$core$Json_Decode$int);
var _elm_lang$html$Html_Events$targetChecked = A2(
	_elm_lang$core$Json_Decode$at,
	{
		ctor: '::',
		_0: 'target',
		_1: {
			ctor: '::',
			_0: 'checked',
			_1: {ctor: '[]'}
		}
	},
	_elm_lang$core$Json_Decode$bool);
var _elm_lang$html$Html_Events$targetValue = A2(
	_elm_lang$core$Json_Decode$at,
	{
		ctor: '::',
		_0: 'target',
		_1: {
			ctor: '::',
			_0: 'value',
			_1: {ctor: '[]'}
		}
	},
	_elm_lang$core$Json_Decode$string);
var _elm_lang$html$Html_Events$defaultOptions = _elm_lang$virtual_dom$VirtualDom$defaultOptions;
var _elm_lang$html$Html_Events$onWithOptions = _elm_lang$virtual_dom$VirtualDom$onWithOptions;
var _elm_lang$html$Html_Events$on = _elm_lang$virtual_dom$VirtualDom$on;
var _elm_lang$html$Html_Events$onFocus = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'focus',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onBlur = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'blur',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onSubmitOptions = _elm_lang$core$Native_Utils.update(
	_elm_lang$html$Html_Events$defaultOptions,
	{preventDefault: true});
var _elm_lang$html$Html_Events$onSubmit = function (msg) {
	return A3(
		_elm_lang$html$Html_Events$onWithOptions,
		'submit',
		_elm_lang$html$Html_Events$onSubmitOptions,
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onCheck = function (tagger) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'change',
		A2(_elm_lang$core$Json_Decode$map, tagger, _elm_lang$html$Html_Events$targetChecked));
};
var _elm_lang$html$Html_Events$onInput = function (tagger) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'input',
		A2(_elm_lang$core$Json_Decode$map, tagger, _elm_lang$html$Html_Events$targetValue));
};
var _elm_lang$html$Html_Events$onMouseOut = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'mouseout',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onMouseOver = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'mouseover',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onMouseLeave = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'mouseleave',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onMouseEnter = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'mouseenter',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onMouseUp = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'mouseup',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onMouseDown = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'mousedown',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onDoubleClick = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'dblclick',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$onClick = function (msg) {
	return A2(
		_elm_lang$html$Html_Events$on,
		'click',
		_elm_lang$core$Json_Decode$succeed(msg));
};
var _elm_lang$html$Html_Events$Options = F2(
	function (a, b) {
		return {stopPropagation: a, preventDefault: b};
	});

var _elm_lang$svg$Svg$map = _elm_lang$virtual_dom$VirtualDom$map;
var _elm_lang$svg$Svg$text = _elm_lang$virtual_dom$VirtualDom$text;
var _elm_lang$svg$Svg$svgNamespace = A2(
	_elm_lang$virtual_dom$VirtualDom$property,
	'namespace',
	_elm_lang$core$Json_Encode$string('http://www.w3.org/2000/svg'));
var _elm_lang$svg$Svg$node = F3(
	function (name, attributes, children) {
		return A3(
			_elm_lang$virtual_dom$VirtualDom$node,
			name,
			{ctor: '::', _0: _elm_lang$svg$Svg$svgNamespace, _1: attributes},
			children);
	});
var _elm_lang$svg$Svg$svg = _elm_lang$svg$Svg$node('svg');
var _elm_lang$svg$Svg$foreignObject = _elm_lang$svg$Svg$node('foreignObject');
var _elm_lang$svg$Svg$animate = _elm_lang$svg$Svg$node('animate');
var _elm_lang$svg$Svg$animateColor = _elm_lang$svg$Svg$node('animateColor');
var _elm_lang$svg$Svg$animateMotion = _elm_lang$svg$Svg$node('animateMotion');
var _elm_lang$svg$Svg$animateTransform = _elm_lang$svg$Svg$node('animateTransform');
var _elm_lang$svg$Svg$mpath = _elm_lang$svg$Svg$node('mpath');
var _elm_lang$svg$Svg$set = _elm_lang$svg$Svg$node('set');
var _elm_lang$svg$Svg$a = _elm_lang$svg$Svg$node('a');
var _elm_lang$svg$Svg$defs = _elm_lang$svg$Svg$node('defs');
var _elm_lang$svg$Svg$g = _elm_lang$svg$Svg$node('g');
var _elm_lang$svg$Svg$marker = _elm_lang$svg$Svg$node('marker');
var _elm_lang$svg$Svg$mask = _elm_lang$svg$Svg$node('mask');
var _elm_lang$svg$Svg$pattern = _elm_lang$svg$Svg$node('pattern');
var _elm_lang$svg$Svg$switch = _elm_lang$svg$Svg$node('switch');
var _elm_lang$svg$Svg$symbol = _elm_lang$svg$Svg$node('symbol');
var _elm_lang$svg$Svg$desc = _elm_lang$svg$Svg$node('desc');
var _elm_lang$svg$Svg$metadata = _elm_lang$svg$Svg$node('metadata');
var _elm_lang$svg$Svg$title = _elm_lang$svg$Svg$node('title');
var _elm_lang$svg$Svg$feBlend = _elm_lang$svg$Svg$node('feBlend');
var _elm_lang$svg$Svg$feColorMatrix = _elm_lang$svg$Svg$node('feColorMatrix');
var _elm_lang$svg$Svg$feComponentTransfer = _elm_lang$svg$Svg$node('feComponentTransfer');
var _elm_lang$svg$Svg$feComposite = _elm_lang$svg$Svg$node('feComposite');
var _elm_lang$svg$Svg$feConvolveMatrix = _elm_lang$svg$Svg$node('feConvolveMatrix');
var _elm_lang$svg$Svg$feDiffuseLighting = _elm_lang$svg$Svg$node('feDiffuseLighting');
var _elm_lang$svg$Svg$feDisplacementMap = _elm_lang$svg$Svg$node('feDisplacementMap');
var _elm_lang$svg$Svg$feFlood = _elm_lang$svg$Svg$node('feFlood');
var _elm_lang$svg$Svg$feFuncA = _elm_lang$svg$Svg$node('feFuncA');
var _elm_lang$svg$Svg$feFuncB = _elm_lang$svg$Svg$node('feFuncB');
var _elm_lang$svg$Svg$feFuncG = _elm_lang$svg$Svg$node('feFuncG');
var _elm_lang$svg$Svg$feFuncR = _elm_lang$svg$Svg$node('feFuncR');
var _elm_lang$svg$Svg$feGaussianBlur = _elm_lang$svg$Svg$node('feGaussianBlur');
var _elm_lang$svg$Svg$feImage = _elm_lang$svg$Svg$node('feImage');
var _elm_lang$svg$Svg$feMerge = _elm_lang$svg$Svg$node('feMerge');
var _elm_lang$svg$Svg$feMergeNode = _elm_lang$svg$Svg$node('feMergeNode');
var _elm_lang$svg$Svg$feMorphology = _elm_lang$svg$Svg$node('feMorphology');
var _elm_lang$svg$Svg$feOffset = _elm_lang$svg$Svg$node('feOffset');
var _elm_lang$svg$Svg$feSpecularLighting = _elm_lang$svg$Svg$node('feSpecularLighting');
var _elm_lang$svg$Svg$feTile = _elm_lang$svg$Svg$node('feTile');
var _elm_lang$svg$Svg$feTurbulence = _elm_lang$svg$Svg$node('feTurbulence');
var _elm_lang$svg$Svg$font = _elm_lang$svg$Svg$node('font');
var _elm_lang$svg$Svg$linearGradient = _elm_lang$svg$Svg$node('linearGradient');
var _elm_lang$svg$Svg$radialGradient = _elm_lang$svg$Svg$node('radialGradient');
var _elm_lang$svg$Svg$stop = _elm_lang$svg$Svg$node('stop');
var _elm_lang$svg$Svg$circle = _elm_lang$svg$Svg$node('circle');
var _elm_lang$svg$Svg$ellipse = _elm_lang$svg$Svg$node('ellipse');
var _elm_lang$svg$Svg$image = _elm_lang$svg$Svg$node('image');
var _elm_lang$svg$Svg$line = _elm_lang$svg$Svg$node('line');
var _elm_lang$svg$Svg$path = _elm_lang$svg$Svg$node('path');
var _elm_lang$svg$Svg$polygon = _elm_lang$svg$Svg$node('polygon');
var _elm_lang$svg$Svg$polyline = _elm_lang$svg$Svg$node('polyline');
var _elm_lang$svg$Svg$rect = _elm_lang$svg$Svg$node('rect');
var _elm_lang$svg$Svg$use = _elm_lang$svg$Svg$node('use');
var _elm_lang$svg$Svg$feDistantLight = _elm_lang$svg$Svg$node('feDistantLight');
var _elm_lang$svg$Svg$fePointLight = _elm_lang$svg$Svg$node('fePointLight');
var _elm_lang$svg$Svg$feSpotLight = _elm_lang$svg$Svg$node('feSpotLight');
var _elm_lang$svg$Svg$altGlyph = _elm_lang$svg$Svg$node('altGlyph');
var _elm_lang$svg$Svg$altGlyphDef = _elm_lang$svg$Svg$node('altGlyphDef');
var _elm_lang$svg$Svg$altGlyphItem = _elm_lang$svg$Svg$node('altGlyphItem');
var _elm_lang$svg$Svg$glyph = _elm_lang$svg$Svg$node('glyph');
var _elm_lang$svg$Svg$glyphRef = _elm_lang$svg$Svg$node('glyphRef');
var _elm_lang$svg$Svg$textPath = _elm_lang$svg$Svg$node('textPath');
var _elm_lang$svg$Svg$text_ = _elm_lang$svg$Svg$node('text');
var _elm_lang$svg$Svg$tref = _elm_lang$svg$Svg$node('tref');
var _elm_lang$svg$Svg$tspan = _elm_lang$svg$Svg$node('tspan');
var _elm_lang$svg$Svg$clipPath = _elm_lang$svg$Svg$node('clipPath');
var _elm_lang$svg$Svg$colorProfile = _elm_lang$svg$Svg$node('colorProfile');
var _elm_lang$svg$Svg$cursor = _elm_lang$svg$Svg$node('cursor');
var _elm_lang$svg$Svg$filter = _elm_lang$svg$Svg$node('filter');
var _elm_lang$svg$Svg$script = _elm_lang$svg$Svg$node('script');
var _elm_lang$svg$Svg$style = _elm_lang$svg$Svg$node('style');
var _elm_lang$svg$Svg$view = _elm_lang$svg$Svg$node('view');

var _elm_lang$svg$Svg_Attributes$writingMode = _elm_lang$virtual_dom$VirtualDom$attribute('writing-mode');
var _elm_lang$svg$Svg_Attributes$wordSpacing = _elm_lang$virtual_dom$VirtualDom$attribute('word-spacing');
var _elm_lang$svg$Svg_Attributes$visibility = _elm_lang$virtual_dom$VirtualDom$attribute('visibility');
var _elm_lang$svg$Svg_Attributes$unicodeBidi = _elm_lang$virtual_dom$VirtualDom$attribute('unicode-bidi');
var _elm_lang$svg$Svg_Attributes$textRendering = _elm_lang$virtual_dom$VirtualDom$attribute('text-rendering');
var _elm_lang$svg$Svg_Attributes$textDecoration = _elm_lang$virtual_dom$VirtualDom$attribute('text-decoration');
var _elm_lang$svg$Svg_Attributes$textAnchor = _elm_lang$virtual_dom$VirtualDom$attribute('text-anchor');
var _elm_lang$svg$Svg_Attributes$stroke = _elm_lang$virtual_dom$VirtualDom$attribute('stroke');
var _elm_lang$svg$Svg_Attributes$strokeWidth = _elm_lang$virtual_dom$VirtualDom$attribute('stroke-width');
var _elm_lang$svg$Svg_Attributes$strokeOpacity = _elm_lang$virtual_dom$VirtualDom$attribute('stroke-opacity');
var _elm_lang$svg$Svg_Attributes$strokeMiterlimit = _elm_lang$virtual_dom$VirtualDom$attribute('stroke-miterlimit');
var _elm_lang$svg$Svg_Attributes$strokeLinejoin = _elm_lang$virtual_dom$VirtualDom$attribute('stroke-linejoin');
var _elm_lang$svg$Svg_Attributes$strokeLinecap = _elm_lang$virtual_dom$VirtualDom$attribute('stroke-linecap');
var _elm_lang$svg$Svg_Attributes$strokeDashoffset = _elm_lang$virtual_dom$VirtualDom$attribute('stroke-dashoffset');
var _elm_lang$svg$Svg_Attributes$strokeDasharray = _elm_lang$virtual_dom$VirtualDom$attribute('stroke-dasharray');
var _elm_lang$svg$Svg_Attributes$stopOpacity = _elm_lang$virtual_dom$VirtualDom$attribute('stop-opacity');
var _elm_lang$svg$Svg_Attributes$stopColor = _elm_lang$virtual_dom$VirtualDom$attribute('stop-color');
var _elm_lang$svg$Svg_Attributes$shapeRendering = _elm_lang$virtual_dom$VirtualDom$attribute('shape-rendering');
var _elm_lang$svg$Svg_Attributes$pointerEvents = _elm_lang$virtual_dom$VirtualDom$attribute('pointer-events');
var _elm_lang$svg$Svg_Attributes$overflow = _elm_lang$virtual_dom$VirtualDom$attribute('overflow');
var _elm_lang$svg$Svg_Attributes$opacity = _elm_lang$virtual_dom$VirtualDom$attribute('opacity');
var _elm_lang$svg$Svg_Attributes$mask = _elm_lang$virtual_dom$VirtualDom$attribute('mask');
var _elm_lang$svg$Svg_Attributes$markerStart = _elm_lang$virtual_dom$VirtualDom$attribute('marker-start');
var _elm_lang$svg$Svg_Attributes$markerMid = _elm_lang$virtual_dom$VirtualDom$attribute('marker-mid');
var _elm_lang$svg$Svg_Attributes$markerEnd = _elm_lang$virtual_dom$VirtualDom$attribute('marker-end');
var _elm_lang$svg$Svg_Attributes$lightingColor = _elm_lang$virtual_dom$VirtualDom$attribute('lighting-color');
var _elm_lang$svg$Svg_Attributes$letterSpacing = _elm_lang$virtual_dom$VirtualDom$attribute('letter-spacing');
var _elm_lang$svg$Svg_Attributes$kerning = _elm_lang$virtual_dom$VirtualDom$attribute('kerning');
var _elm_lang$svg$Svg_Attributes$imageRendering = _elm_lang$virtual_dom$VirtualDom$attribute('image-rendering');
var _elm_lang$svg$Svg_Attributes$glyphOrientationVertical = _elm_lang$virtual_dom$VirtualDom$attribute('glyph-orientation-vertical');
var _elm_lang$svg$Svg_Attributes$glyphOrientationHorizontal = _elm_lang$virtual_dom$VirtualDom$attribute('glyph-orientation-horizontal');
var _elm_lang$svg$Svg_Attributes$fontWeight = _elm_lang$virtual_dom$VirtualDom$attribute('font-weight');
var _elm_lang$svg$Svg_Attributes$fontVariant = _elm_lang$virtual_dom$VirtualDom$attribute('font-variant');
var _elm_lang$svg$Svg_Attributes$fontStyle = _elm_lang$virtual_dom$VirtualDom$attribute('font-style');
var _elm_lang$svg$Svg_Attributes$fontStretch = _elm_lang$virtual_dom$VirtualDom$attribute('font-stretch');
var _elm_lang$svg$Svg_Attributes$fontSize = _elm_lang$virtual_dom$VirtualDom$attribute('font-size');
var _elm_lang$svg$Svg_Attributes$fontSizeAdjust = _elm_lang$virtual_dom$VirtualDom$attribute('font-size-adjust');
var _elm_lang$svg$Svg_Attributes$fontFamily = _elm_lang$virtual_dom$VirtualDom$attribute('font-family');
var _elm_lang$svg$Svg_Attributes$floodOpacity = _elm_lang$virtual_dom$VirtualDom$attribute('flood-opacity');
var _elm_lang$svg$Svg_Attributes$floodColor = _elm_lang$virtual_dom$VirtualDom$attribute('flood-color');
var _elm_lang$svg$Svg_Attributes$filter = _elm_lang$virtual_dom$VirtualDom$attribute('filter');
var _elm_lang$svg$Svg_Attributes$fill = _elm_lang$virtual_dom$VirtualDom$attribute('fill');
var _elm_lang$svg$Svg_Attributes$fillRule = _elm_lang$virtual_dom$VirtualDom$attribute('fill-rule');
var _elm_lang$svg$Svg_Attributes$fillOpacity = _elm_lang$virtual_dom$VirtualDom$attribute('fill-opacity');
var _elm_lang$svg$Svg_Attributes$enableBackground = _elm_lang$virtual_dom$VirtualDom$attribute('enable-background');
var _elm_lang$svg$Svg_Attributes$dominantBaseline = _elm_lang$virtual_dom$VirtualDom$attribute('dominant-baseline');
var _elm_lang$svg$Svg_Attributes$display = _elm_lang$virtual_dom$VirtualDom$attribute('display');
var _elm_lang$svg$Svg_Attributes$direction = _elm_lang$virtual_dom$VirtualDom$attribute('direction');
var _elm_lang$svg$Svg_Attributes$cursor = _elm_lang$virtual_dom$VirtualDom$attribute('cursor');
var _elm_lang$svg$Svg_Attributes$color = _elm_lang$virtual_dom$VirtualDom$attribute('color');
var _elm_lang$svg$Svg_Attributes$colorRendering = _elm_lang$virtual_dom$VirtualDom$attribute('color-rendering');
var _elm_lang$svg$Svg_Attributes$colorProfile = _elm_lang$virtual_dom$VirtualDom$attribute('color-profile');
var _elm_lang$svg$Svg_Attributes$colorInterpolation = _elm_lang$virtual_dom$VirtualDom$attribute('color-interpolation');
var _elm_lang$svg$Svg_Attributes$colorInterpolationFilters = _elm_lang$virtual_dom$VirtualDom$attribute('color-interpolation-filters');
var _elm_lang$svg$Svg_Attributes$clip = _elm_lang$virtual_dom$VirtualDom$attribute('clip');
var _elm_lang$svg$Svg_Attributes$clipRule = _elm_lang$virtual_dom$VirtualDom$attribute('clip-rule');
var _elm_lang$svg$Svg_Attributes$clipPath = _elm_lang$virtual_dom$VirtualDom$attribute('clip-path');
var _elm_lang$svg$Svg_Attributes$baselineShift = _elm_lang$virtual_dom$VirtualDom$attribute('baseline-shift');
var _elm_lang$svg$Svg_Attributes$alignmentBaseline = _elm_lang$virtual_dom$VirtualDom$attribute('alignment-baseline');
var _elm_lang$svg$Svg_Attributes$zoomAndPan = _elm_lang$virtual_dom$VirtualDom$attribute('zoomAndPan');
var _elm_lang$svg$Svg_Attributes$z = _elm_lang$virtual_dom$VirtualDom$attribute('z');
var _elm_lang$svg$Svg_Attributes$yChannelSelector = _elm_lang$virtual_dom$VirtualDom$attribute('yChannelSelector');
var _elm_lang$svg$Svg_Attributes$y2 = _elm_lang$virtual_dom$VirtualDom$attribute('y2');
var _elm_lang$svg$Svg_Attributes$y1 = _elm_lang$virtual_dom$VirtualDom$attribute('y1');
var _elm_lang$svg$Svg_Attributes$y = _elm_lang$virtual_dom$VirtualDom$attribute('y');
var _elm_lang$svg$Svg_Attributes$xmlSpace = A2(_elm_lang$virtual_dom$VirtualDom$attributeNS, 'http://www.w3.org/XML/1998/namespace', 'xml:space');
var _elm_lang$svg$Svg_Attributes$xmlLang = A2(_elm_lang$virtual_dom$VirtualDom$attributeNS, 'http://www.w3.org/XML/1998/namespace', 'xml:lang');
var _elm_lang$svg$Svg_Attributes$xmlBase = A2(_elm_lang$virtual_dom$VirtualDom$attributeNS, 'http://www.w3.org/XML/1998/namespace', 'xml:base');
var _elm_lang$svg$Svg_Attributes$xlinkType = A2(_elm_lang$virtual_dom$VirtualDom$attributeNS, 'http://www.w3.org/1999/xlink', 'xlink:type');
var _elm_lang$svg$Svg_Attributes$xlinkTitle = A2(_elm_lang$virtual_dom$VirtualDom$attributeNS, 'http://www.w3.org/1999/xlink', 'xlink:title');
var _elm_lang$svg$Svg_Attributes$xlinkShow = A2(_elm_lang$virtual_dom$VirtualDom$attributeNS, 'http://www.w3.org/1999/xlink', 'xlink:show');
var _elm_lang$svg$Svg_Attributes$xlinkRole = A2(_elm_lang$virtual_dom$VirtualDom$attributeNS, 'http://www.w3.org/1999/xlink', 'xlink:role');
var _elm_lang$svg$Svg_Attributes$xlinkHref = A2(_elm_lang$virtual_dom$VirtualDom$attributeNS, 'http://www.w3.org/1999/xlink', 'xlink:href');
var _elm_lang$svg$Svg_Attributes$xlinkArcrole = A2(_elm_lang$virtual_dom$VirtualDom$attributeNS, 'http://www.w3.org/1999/xlink', 'xlink:arcrole');
var _elm_lang$svg$Svg_Attributes$xlinkActuate = A2(_elm_lang$virtual_dom$VirtualDom$attributeNS, 'http://www.w3.org/1999/xlink', 'xlink:actuate');
var _elm_lang$svg$Svg_Attributes$xChannelSelector = _elm_lang$virtual_dom$VirtualDom$attribute('xChannelSelector');
var _elm_lang$svg$Svg_Attributes$x2 = _elm_lang$virtual_dom$VirtualDom$attribute('x2');
var _elm_lang$svg$Svg_Attributes$x1 = _elm_lang$virtual_dom$VirtualDom$attribute('x1');
var _elm_lang$svg$Svg_Attributes$xHeight = _elm_lang$virtual_dom$VirtualDom$attribute('x-height');
var _elm_lang$svg$Svg_Attributes$x = _elm_lang$virtual_dom$VirtualDom$attribute('x');
var _elm_lang$svg$Svg_Attributes$widths = _elm_lang$virtual_dom$VirtualDom$attribute('widths');
var _elm_lang$svg$Svg_Attributes$width = _elm_lang$virtual_dom$VirtualDom$attribute('width');
var _elm_lang$svg$Svg_Attributes$viewTarget = _elm_lang$virtual_dom$VirtualDom$attribute('viewTarget');
var _elm_lang$svg$Svg_Attributes$viewBox = _elm_lang$virtual_dom$VirtualDom$attribute('viewBox');
var _elm_lang$svg$Svg_Attributes$vertOriginY = _elm_lang$virtual_dom$VirtualDom$attribute('vert-origin-y');
var _elm_lang$svg$Svg_Attributes$vertOriginX = _elm_lang$virtual_dom$VirtualDom$attribute('vert-origin-x');
var _elm_lang$svg$Svg_Attributes$vertAdvY = _elm_lang$virtual_dom$VirtualDom$attribute('vert-adv-y');
var _elm_lang$svg$Svg_Attributes$version = _elm_lang$virtual_dom$VirtualDom$attribute('version');
var _elm_lang$svg$Svg_Attributes$values = _elm_lang$virtual_dom$VirtualDom$attribute('values');
var _elm_lang$svg$Svg_Attributes$vMathematical = _elm_lang$virtual_dom$VirtualDom$attribute('v-mathematical');
var _elm_lang$svg$Svg_Attributes$vIdeographic = _elm_lang$virtual_dom$VirtualDom$attribute('v-ideographic');
var _elm_lang$svg$Svg_Attributes$vHanging = _elm_lang$virtual_dom$VirtualDom$attribute('v-hanging');
var _elm_lang$svg$Svg_Attributes$vAlphabetic = _elm_lang$virtual_dom$VirtualDom$attribute('v-alphabetic');
var _elm_lang$svg$Svg_Attributes$unitsPerEm = _elm_lang$virtual_dom$VirtualDom$attribute('units-per-em');
var _elm_lang$svg$Svg_Attributes$unicodeRange = _elm_lang$virtual_dom$VirtualDom$attribute('unicode-range');
var _elm_lang$svg$Svg_Attributes$unicode = _elm_lang$virtual_dom$VirtualDom$attribute('unicode');
var _elm_lang$svg$Svg_Attributes$underlineThickness = _elm_lang$virtual_dom$VirtualDom$attribute('underline-thickness');
var _elm_lang$svg$Svg_Attributes$underlinePosition = _elm_lang$virtual_dom$VirtualDom$attribute('underline-position');
var _elm_lang$svg$Svg_Attributes$u2 = _elm_lang$virtual_dom$VirtualDom$attribute('u2');
var _elm_lang$svg$Svg_Attributes$u1 = _elm_lang$virtual_dom$VirtualDom$attribute('u1');
var _elm_lang$svg$Svg_Attributes$type_ = _elm_lang$virtual_dom$VirtualDom$attribute('type');
var _elm_lang$svg$Svg_Attributes$transform = _elm_lang$virtual_dom$VirtualDom$attribute('transform');
var _elm_lang$svg$Svg_Attributes$to = _elm_lang$virtual_dom$VirtualDom$attribute('to');
var _elm_lang$svg$Svg_Attributes$title = _elm_lang$virtual_dom$VirtualDom$attribute('title');
var _elm_lang$svg$Svg_Attributes$textLength = _elm_lang$virtual_dom$VirtualDom$attribute('textLength');
var _elm_lang$svg$Svg_Attributes$targetY = _elm_lang$virtual_dom$VirtualDom$attribute('targetY');
var _elm_lang$svg$Svg_Attributes$targetX = _elm_lang$virtual_dom$VirtualDom$attribute('targetX');
var _elm_lang$svg$Svg_Attributes$target = _elm_lang$virtual_dom$VirtualDom$attribute('target');
var _elm_lang$svg$Svg_Attributes$tableValues = _elm_lang$virtual_dom$VirtualDom$attribute('tableValues');
var _elm_lang$svg$Svg_Attributes$systemLanguage = _elm_lang$virtual_dom$VirtualDom$attribute('systemLanguage');
var _elm_lang$svg$Svg_Attributes$surfaceScale = _elm_lang$virtual_dom$VirtualDom$attribute('surfaceScale');
var _elm_lang$svg$Svg_Attributes$style = _elm_lang$virtual_dom$VirtualDom$attribute('style');
var _elm_lang$svg$Svg_Attributes$string = _elm_lang$virtual_dom$VirtualDom$attribute('string');
var _elm_lang$svg$Svg_Attributes$strikethroughThickness = _elm_lang$virtual_dom$VirtualDom$attribute('strikethrough-thickness');
var _elm_lang$svg$Svg_Attributes$strikethroughPosition = _elm_lang$virtual_dom$VirtualDom$attribute('strikethrough-position');
var _elm_lang$svg$Svg_Attributes$stitchTiles = _elm_lang$virtual_dom$VirtualDom$attribute('stitchTiles');
var _elm_lang$svg$Svg_Attributes$stemv = _elm_lang$virtual_dom$VirtualDom$attribute('stemv');
var _elm_lang$svg$Svg_Attributes$stemh = _elm_lang$virtual_dom$VirtualDom$attribute('stemh');
var _elm_lang$svg$Svg_Attributes$stdDeviation = _elm_lang$virtual_dom$VirtualDom$attribute('stdDeviation');
var _elm_lang$svg$Svg_Attributes$startOffset = _elm_lang$virtual_dom$VirtualDom$attribute('startOffset');
var _elm_lang$svg$Svg_Attributes$spreadMethod = _elm_lang$virtual_dom$VirtualDom$attribute('spreadMethod');
var _elm_lang$svg$Svg_Attributes$speed = _elm_lang$virtual_dom$VirtualDom$attribute('speed');
var _elm_lang$svg$Svg_Attributes$specularExponent = _elm_lang$virtual_dom$VirtualDom$attribute('specularExponent');
var _elm_lang$svg$Svg_Attributes$specularConstant = _elm_lang$virtual_dom$VirtualDom$attribute('specularConstant');
var _elm_lang$svg$Svg_Attributes$spacing = _elm_lang$virtual_dom$VirtualDom$attribute('spacing');
var _elm_lang$svg$Svg_Attributes$slope = _elm_lang$virtual_dom$VirtualDom$attribute('slope');
var _elm_lang$svg$Svg_Attributes$seed = _elm_lang$virtual_dom$VirtualDom$attribute('seed');
var _elm_lang$svg$Svg_Attributes$scale = _elm_lang$virtual_dom$VirtualDom$attribute('scale');
var _elm_lang$svg$Svg_Attributes$ry = _elm_lang$virtual_dom$VirtualDom$attribute('ry');
var _elm_lang$svg$Svg_Attributes$rx = _elm_lang$virtual_dom$VirtualDom$attribute('rx');
var _elm_lang$svg$Svg_Attributes$rotate = _elm_lang$virtual_dom$VirtualDom$attribute('rotate');
var _elm_lang$svg$Svg_Attributes$result = _elm_lang$virtual_dom$VirtualDom$attribute('result');
var _elm_lang$svg$Svg_Attributes$restart = _elm_lang$virtual_dom$VirtualDom$attribute('restart');
var _elm_lang$svg$Svg_Attributes$requiredFeatures = _elm_lang$virtual_dom$VirtualDom$attribute('requiredFeatures');
var _elm_lang$svg$Svg_Attributes$requiredExtensions = _elm_lang$virtual_dom$VirtualDom$attribute('requiredExtensions');
var _elm_lang$svg$Svg_Attributes$repeatDur = _elm_lang$virtual_dom$VirtualDom$attribute('repeatDur');
var _elm_lang$svg$Svg_Attributes$repeatCount = _elm_lang$virtual_dom$VirtualDom$attribute('repeatCount');
var _elm_lang$svg$Svg_Attributes$renderingIntent = _elm_lang$virtual_dom$VirtualDom$attribute('rendering-intent');
var _elm_lang$svg$Svg_Attributes$refY = _elm_lang$virtual_dom$VirtualDom$attribute('refY');
var _elm_lang$svg$Svg_Attributes$refX = _elm_lang$virtual_dom$VirtualDom$attribute('refX');
var _elm_lang$svg$Svg_Attributes$radius = _elm_lang$virtual_dom$VirtualDom$attribute('radius');
var _elm_lang$svg$Svg_Attributes$r = _elm_lang$virtual_dom$VirtualDom$attribute('r');
var _elm_lang$svg$Svg_Attributes$primitiveUnits = _elm_lang$virtual_dom$VirtualDom$attribute('primitiveUnits');
var _elm_lang$svg$Svg_Attributes$preserveAspectRatio = _elm_lang$virtual_dom$VirtualDom$attribute('preserveAspectRatio');
var _elm_lang$svg$Svg_Attributes$preserveAlpha = _elm_lang$virtual_dom$VirtualDom$attribute('preserveAlpha');
var _elm_lang$svg$Svg_Attributes$pointsAtZ = _elm_lang$virtual_dom$VirtualDom$attribute('pointsAtZ');
var _elm_lang$svg$Svg_Attributes$pointsAtY = _elm_lang$virtual_dom$VirtualDom$attribute('pointsAtY');
var _elm_lang$svg$Svg_Attributes$pointsAtX = _elm_lang$virtual_dom$VirtualDom$attribute('pointsAtX');
var _elm_lang$svg$Svg_Attributes$points = _elm_lang$virtual_dom$VirtualDom$attribute('points');
var _elm_lang$svg$Svg_Attributes$pointOrder = _elm_lang$virtual_dom$VirtualDom$attribute('point-order');
var _elm_lang$svg$Svg_Attributes$patternUnits = _elm_lang$virtual_dom$VirtualDom$attribute('patternUnits');
var _elm_lang$svg$Svg_Attributes$patternTransform = _elm_lang$virtual_dom$VirtualDom$attribute('patternTransform');
var _elm_lang$svg$Svg_Attributes$patternContentUnits = _elm_lang$virtual_dom$VirtualDom$attribute('patternContentUnits');
var _elm_lang$svg$Svg_Attributes$pathLength = _elm_lang$virtual_dom$VirtualDom$attribute('pathLength');
var _elm_lang$svg$Svg_Attributes$path = _elm_lang$virtual_dom$VirtualDom$attribute('path');
var _elm_lang$svg$Svg_Attributes$panose1 = _elm_lang$virtual_dom$VirtualDom$attribute('panose-1');
var _elm_lang$svg$Svg_Attributes$overlineThickness = _elm_lang$virtual_dom$VirtualDom$attribute('overline-thickness');
var _elm_lang$svg$Svg_Attributes$overlinePosition = _elm_lang$virtual_dom$VirtualDom$attribute('overline-position');
var _elm_lang$svg$Svg_Attributes$origin = _elm_lang$virtual_dom$VirtualDom$attribute('origin');
var _elm_lang$svg$Svg_Attributes$orientation = _elm_lang$virtual_dom$VirtualDom$attribute('orientation');
var _elm_lang$svg$Svg_Attributes$orient = _elm_lang$virtual_dom$VirtualDom$attribute('orient');
var _elm_lang$svg$Svg_Attributes$order = _elm_lang$virtual_dom$VirtualDom$attribute('order');
var _elm_lang$svg$Svg_Attributes$operator = _elm_lang$virtual_dom$VirtualDom$attribute('operator');
var _elm_lang$svg$Svg_Attributes$offset = _elm_lang$virtual_dom$VirtualDom$attribute('offset');
var _elm_lang$svg$Svg_Attributes$numOctaves = _elm_lang$virtual_dom$VirtualDom$attribute('numOctaves');
var _elm_lang$svg$Svg_Attributes$name = _elm_lang$virtual_dom$VirtualDom$attribute('name');
var _elm_lang$svg$Svg_Attributes$mode = _elm_lang$virtual_dom$VirtualDom$attribute('mode');
var _elm_lang$svg$Svg_Attributes$min = _elm_lang$virtual_dom$VirtualDom$attribute('min');
var _elm_lang$svg$Svg_Attributes$method = _elm_lang$virtual_dom$VirtualDom$attribute('method');
var _elm_lang$svg$Svg_Attributes$media = _elm_lang$virtual_dom$VirtualDom$attribute('media');
var _elm_lang$svg$Svg_Attributes$max = _elm_lang$virtual_dom$VirtualDom$attribute('max');
var _elm_lang$svg$Svg_Attributes$mathematical = _elm_lang$virtual_dom$VirtualDom$attribute('mathematical');
var _elm_lang$svg$Svg_Attributes$maskUnits = _elm_lang$virtual_dom$VirtualDom$attribute('maskUnits');
var _elm_lang$svg$Svg_Attributes$maskContentUnits = _elm_lang$virtual_dom$VirtualDom$attribute('maskContentUnits');
var _elm_lang$svg$Svg_Attributes$markerWidth = _elm_lang$virtual_dom$VirtualDom$attribute('markerWidth');
var _elm_lang$svg$Svg_Attributes$markerUnits = _elm_lang$virtual_dom$VirtualDom$attribute('markerUnits');
var _elm_lang$svg$Svg_Attributes$markerHeight = _elm_lang$virtual_dom$VirtualDom$attribute('markerHeight');
var _elm_lang$svg$Svg_Attributes$local = _elm_lang$virtual_dom$VirtualDom$attribute('local');
var _elm_lang$svg$Svg_Attributes$limitingConeAngle = _elm_lang$virtual_dom$VirtualDom$attribute('limitingConeAngle');
var _elm_lang$svg$Svg_Attributes$lengthAdjust = _elm_lang$virtual_dom$VirtualDom$attribute('lengthAdjust');
var _elm_lang$svg$Svg_Attributes$lang = _elm_lang$virtual_dom$VirtualDom$attribute('lang');
var _elm_lang$svg$Svg_Attributes$keyTimes = _elm_lang$virtual_dom$VirtualDom$attribute('keyTimes');
var _elm_lang$svg$Svg_Attributes$keySplines = _elm_lang$virtual_dom$VirtualDom$attribute('keySplines');
var _elm_lang$svg$Svg_Attributes$keyPoints = _elm_lang$virtual_dom$VirtualDom$attribute('keyPoints');
var _elm_lang$svg$Svg_Attributes$kernelUnitLength = _elm_lang$virtual_dom$VirtualDom$attribute('kernelUnitLength');
var _elm_lang$svg$Svg_Attributes$kernelMatrix = _elm_lang$virtual_dom$VirtualDom$attribute('kernelMatrix');
var _elm_lang$svg$Svg_Attributes$k4 = _elm_lang$virtual_dom$VirtualDom$attribute('k4');
var _elm_lang$svg$Svg_Attributes$k3 = _elm_lang$virtual_dom$VirtualDom$attribute('k3');
var _elm_lang$svg$Svg_Attributes$k2 = _elm_lang$virtual_dom$VirtualDom$attribute('k2');
var _elm_lang$svg$Svg_Attributes$k1 = _elm_lang$virtual_dom$VirtualDom$attribute('k1');
var _elm_lang$svg$Svg_Attributes$k = _elm_lang$virtual_dom$VirtualDom$attribute('k');
var _elm_lang$svg$Svg_Attributes$intercept = _elm_lang$virtual_dom$VirtualDom$attribute('intercept');
var _elm_lang$svg$Svg_Attributes$in2 = _elm_lang$virtual_dom$VirtualDom$attribute('in2');
var _elm_lang$svg$Svg_Attributes$in_ = _elm_lang$virtual_dom$VirtualDom$attribute('in');
var _elm_lang$svg$Svg_Attributes$ideographic = _elm_lang$virtual_dom$VirtualDom$attribute('ideographic');
var _elm_lang$svg$Svg_Attributes$id = _elm_lang$virtual_dom$VirtualDom$attribute('id');
var _elm_lang$svg$Svg_Attributes$horizOriginY = _elm_lang$virtual_dom$VirtualDom$attribute('horiz-origin-y');
var _elm_lang$svg$Svg_Attributes$horizOriginX = _elm_lang$virtual_dom$VirtualDom$attribute('horiz-origin-x');
var _elm_lang$svg$Svg_Attributes$horizAdvX = _elm_lang$virtual_dom$VirtualDom$attribute('horiz-adv-x');
var _elm_lang$svg$Svg_Attributes$height = _elm_lang$virtual_dom$VirtualDom$attribute('height');
var _elm_lang$svg$Svg_Attributes$hanging = _elm_lang$virtual_dom$VirtualDom$attribute('hanging');
var _elm_lang$svg$Svg_Attributes$gradientUnits = _elm_lang$virtual_dom$VirtualDom$attribute('gradientUnits');
var _elm_lang$svg$Svg_Attributes$gradientTransform = _elm_lang$virtual_dom$VirtualDom$attribute('gradientTransform');
var _elm_lang$svg$Svg_Attributes$glyphRef = _elm_lang$virtual_dom$VirtualDom$attribute('glyphRef');
var _elm_lang$svg$Svg_Attributes$glyphName = _elm_lang$virtual_dom$VirtualDom$attribute('glyph-name');
var _elm_lang$svg$Svg_Attributes$g2 = _elm_lang$virtual_dom$VirtualDom$attribute('g2');
var _elm_lang$svg$Svg_Attributes$g1 = _elm_lang$virtual_dom$VirtualDom$attribute('g1');
var _elm_lang$svg$Svg_Attributes$fy = _elm_lang$virtual_dom$VirtualDom$attribute('fy');
var _elm_lang$svg$Svg_Attributes$fx = _elm_lang$virtual_dom$VirtualDom$attribute('fx');
var _elm_lang$svg$Svg_Attributes$from = _elm_lang$virtual_dom$VirtualDom$attribute('from');
var _elm_lang$svg$Svg_Attributes$format = _elm_lang$virtual_dom$VirtualDom$attribute('format');
var _elm_lang$svg$Svg_Attributes$filterUnits = _elm_lang$virtual_dom$VirtualDom$attribute('filterUnits');
var _elm_lang$svg$Svg_Attributes$filterRes = _elm_lang$virtual_dom$VirtualDom$attribute('filterRes');
var _elm_lang$svg$Svg_Attributes$externalResourcesRequired = _elm_lang$virtual_dom$VirtualDom$attribute('externalResourcesRequired');
var _elm_lang$svg$Svg_Attributes$exponent = _elm_lang$virtual_dom$VirtualDom$attribute('exponent');
var _elm_lang$svg$Svg_Attributes$end = _elm_lang$virtual_dom$VirtualDom$attribute('end');
var _elm_lang$svg$Svg_Attributes$elevation = _elm_lang$virtual_dom$VirtualDom$attribute('elevation');
var _elm_lang$svg$Svg_Attributes$edgeMode = _elm_lang$virtual_dom$VirtualDom$attribute('edgeMode');
var _elm_lang$svg$Svg_Attributes$dy = _elm_lang$virtual_dom$VirtualDom$attribute('dy');
var _elm_lang$svg$Svg_Attributes$dx = _elm_lang$virtual_dom$VirtualDom$attribute('dx');
var _elm_lang$svg$Svg_Attributes$dur = _elm_lang$virtual_dom$VirtualDom$attribute('dur');
var _elm_lang$svg$Svg_Attributes$divisor = _elm_lang$virtual_dom$VirtualDom$attribute('divisor');
var _elm_lang$svg$Svg_Attributes$diffuseConstant = _elm_lang$virtual_dom$VirtualDom$attribute('diffuseConstant');
var _elm_lang$svg$Svg_Attributes$descent = _elm_lang$virtual_dom$VirtualDom$attribute('descent');
var _elm_lang$svg$Svg_Attributes$decelerate = _elm_lang$virtual_dom$VirtualDom$attribute('decelerate');
var _elm_lang$svg$Svg_Attributes$d = _elm_lang$virtual_dom$VirtualDom$attribute('d');
var _elm_lang$svg$Svg_Attributes$cy = _elm_lang$virtual_dom$VirtualDom$attribute('cy');
var _elm_lang$svg$Svg_Attributes$cx = _elm_lang$virtual_dom$VirtualDom$attribute('cx');
var _elm_lang$svg$Svg_Attributes$contentStyleType = _elm_lang$virtual_dom$VirtualDom$attribute('contentStyleType');
var _elm_lang$svg$Svg_Attributes$contentScriptType = _elm_lang$virtual_dom$VirtualDom$attribute('contentScriptType');
var _elm_lang$svg$Svg_Attributes$clipPathUnits = _elm_lang$virtual_dom$VirtualDom$attribute('clipPathUnits');
var _elm_lang$svg$Svg_Attributes$class = _elm_lang$virtual_dom$VirtualDom$attribute('class');
var _elm_lang$svg$Svg_Attributes$capHeight = _elm_lang$virtual_dom$VirtualDom$attribute('cap-height');
var _elm_lang$svg$Svg_Attributes$calcMode = _elm_lang$virtual_dom$VirtualDom$attribute('calcMode');
var _elm_lang$svg$Svg_Attributes$by = _elm_lang$virtual_dom$VirtualDom$attribute('by');
var _elm_lang$svg$Svg_Attributes$bias = _elm_lang$virtual_dom$VirtualDom$attribute('bias');
var _elm_lang$svg$Svg_Attributes$begin = _elm_lang$virtual_dom$VirtualDom$attribute('begin');
var _elm_lang$svg$Svg_Attributes$bbox = _elm_lang$virtual_dom$VirtualDom$attribute('bbox');
var _elm_lang$svg$Svg_Attributes$baseProfile = _elm_lang$virtual_dom$VirtualDom$attribute('baseProfile');
var _elm_lang$svg$Svg_Attributes$baseFrequency = _elm_lang$virtual_dom$VirtualDom$attribute('baseFrequency');
var _elm_lang$svg$Svg_Attributes$azimuth = _elm_lang$virtual_dom$VirtualDom$attribute('azimuth');
var _elm_lang$svg$Svg_Attributes$autoReverse = _elm_lang$virtual_dom$VirtualDom$attribute('autoReverse');
var _elm_lang$svg$Svg_Attributes$attributeType = _elm_lang$virtual_dom$VirtualDom$attribute('attributeType');
var _elm_lang$svg$Svg_Attributes$attributeName = _elm_lang$virtual_dom$VirtualDom$attribute('attributeName');
var _elm_lang$svg$Svg_Attributes$ascent = _elm_lang$virtual_dom$VirtualDom$attribute('ascent');
var _elm_lang$svg$Svg_Attributes$arabicForm = _elm_lang$virtual_dom$VirtualDom$attribute('arabic-form');
var _elm_lang$svg$Svg_Attributes$amplitude = _elm_lang$virtual_dom$VirtualDom$attribute('amplitude');
var _elm_lang$svg$Svg_Attributes$allowReorder = _elm_lang$virtual_dom$VirtualDom$attribute('allowReorder');
var _elm_lang$svg$Svg_Attributes$alphabetic = _elm_lang$virtual_dom$VirtualDom$attribute('alphabetic');
var _elm_lang$svg$Svg_Attributes$additive = _elm_lang$virtual_dom$VirtualDom$attribute('additive');
var _elm_lang$svg$Svg_Attributes$accumulate = _elm_lang$virtual_dom$VirtualDom$attribute('accumulate');
var _elm_lang$svg$Svg_Attributes$accelerate = _elm_lang$virtual_dom$VirtualDom$attribute('accelerate');
var _elm_lang$svg$Svg_Attributes$accentHeight = _elm_lang$virtual_dom$VirtualDom$attribute('accent-height');

var _elm_lang$svg$Svg_Lazy$lazy3 = _elm_lang$virtual_dom$VirtualDom$lazy3;
var _elm_lang$svg$Svg_Lazy$lazy2 = _elm_lang$virtual_dom$VirtualDom$lazy2;
var _elm_lang$svg$Svg_Lazy$lazy = _elm_lang$virtual_dom$VirtualDom$lazy;

var _myrho$elm_round$Round$funNum = F3(
	function (fun, s, fl) {
		return A2(
			_elm_lang$core$Maybe$withDefault,
			1 / 0,
			_elm_lang$core$Result$toMaybe(
				_elm_lang$core$String$toFloat(
					A2(fun, s, fl))));
	});
var _myrho$elm_round$Round$splitComma = function (str) {
	var _p0 = A2(_elm_lang$core$String$split, '.', str);
	if (_p0.ctor === '::') {
		if (_p0._1.ctor === '::') {
			return {ctor: '_Tuple2', _0: _p0._0, _1: _p0._1._0};
		} else {
			return {ctor: '_Tuple2', _0: _p0._0, _1: '0'};
		}
	} else {
		return {ctor: '_Tuple2', _0: '0', _1: '0'};
	}
};
var _myrho$elm_round$Round$toDecimal = function (fl) {
	var _p1 = A2(
		_elm_lang$core$String$split,
		'e',
		_elm_lang$core$Basics$toString(fl));
	if (_p1.ctor === '::') {
		if (_p1._1.ctor === '::') {
			var _p4 = _p1._1._0;
			var _p2 = function () {
				var hasSign = _elm_lang$core$Native_Utils.cmp(fl, 0) < 0;
				var _p3 = _myrho$elm_round$Round$splitComma(_p1._0);
				var b = _p3._0;
				var a = _p3._1;
				return {
					ctor: '_Tuple3',
					_0: hasSign ? '-' : '',
					_1: hasSign ? A2(_elm_lang$core$String$dropLeft, 1, b) : b,
					_2: a
				};
			}();
			var sign = _p2._0;
			var before = _p2._1;
			var after = _p2._2;
			var e = A2(
				_elm_lang$core$Maybe$withDefault,
				0,
				_elm_lang$core$Result$toMaybe(
					_elm_lang$core$String$toInt(
						A2(_elm_lang$core$String$startsWith, '+', _p4) ? A2(_elm_lang$core$String$dropLeft, 1, _p4) : _p4)));
			var newBefore = (_elm_lang$core$Native_Utils.cmp(e, 0) > -1) ? before : ((_elm_lang$core$Native_Utils.cmp(
				_elm_lang$core$Basics$abs(e),
				_elm_lang$core$String$length(before)) < 0) ? A2(
				_elm_lang$core$Basics_ops['++'],
				A2(
					_elm_lang$core$String$left,
					_elm_lang$core$String$length(before) - _elm_lang$core$Basics$abs(e),
					before),
				A2(
					_elm_lang$core$Basics_ops['++'],
					'.',
					A2(
						_elm_lang$core$String$right,
						_elm_lang$core$Basics$abs(e),
						before))) : A2(
				_elm_lang$core$Basics_ops['++'],
				'0.',
				A2(
					_elm_lang$core$Basics_ops['++'],
					A2(
						_elm_lang$core$String$repeat,
						_elm_lang$core$Basics$abs(e) - _elm_lang$core$String$length(before),
						'0'),
					before)));
			var newAfter = (_elm_lang$core$Native_Utils.cmp(e, 0) < 1) ? after : ((_elm_lang$core$Native_Utils.cmp(
				e,
				_elm_lang$core$String$length(after)) < 0) ? A2(
				_elm_lang$core$Basics_ops['++'],
				A2(_elm_lang$core$String$left, e, after),
				A2(
					_elm_lang$core$Basics_ops['++'],
					'.',
					A2(
						_elm_lang$core$String$right,
						_elm_lang$core$String$length(after) - e,
						after))) : A2(
				_elm_lang$core$Basics_ops['++'],
				after,
				A2(
					_elm_lang$core$String$repeat,
					e - _elm_lang$core$String$length(after),
					'0')));
			return A2(
				_elm_lang$core$Basics_ops['++'],
				sign,
				A2(_elm_lang$core$Basics_ops['++'], newBefore, newAfter));
		} else {
			return _p1._0;
		}
	} else {
		return '';
	}
};
var _myrho$elm_round$Round$truncate = function (n) {
	return (_elm_lang$core$Native_Utils.cmp(n, 0) < 0) ? _elm_lang$core$Basics$ceiling(n) : _elm_lang$core$Basics$floor(n);
};
var _myrho$elm_round$Round$roundFun = F3(
	function (functor, s, fl) {
		if (_elm_lang$core$Native_Utils.cmp(s, 0) < 1) {
			return _elm_lang$core$Basics$toString(
				functor(fl));
		} else {
			var dd = (_elm_lang$core$Native_Utils.cmp(fl, 0) < 0) ? 2 : 1;
			var n = (_elm_lang$core$Native_Utils.cmp(fl, 0) < 0) ? -1 : 1;
			var e = Math.pow(10, s);
			var _p5 = _myrho$elm_round$Round$splitComma(
				_myrho$elm_round$Round$toDecimal(fl));
			var before = _p5._0;
			var after = _p5._1;
			var a = A3(
				_elm_lang$core$String$padRight,
				s + 1,
				_elm_lang$core$Native_Utils.chr('0'),
				after);
			var b = A2(_elm_lang$core$String$left, s, a);
			var c = A2(_elm_lang$core$String$dropLeft, s, a);
			var f = functor(
				A2(
					_elm_lang$core$Maybe$withDefault,
					_elm_lang$core$Basics$toFloat(e),
					_elm_lang$core$Result$toMaybe(
						_elm_lang$core$String$toFloat(
							A2(
								_elm_lang$core$Basics_ops['++'],
								(_elm_lang$core$Native_Utils.cmp(fl, 0) < 0) ? '-' : '',
								A2(
									_elm_lang$core$Basics_ops['++'],
									'1',
									A2(
										_elm_lang$core$Basics_ops['++'],
										b,
										A2(_elm_lang$core$Basics_ops['++'], '.', c))))))));
			var g = A2(
				_elm_lang$core$String$dropLeft,
				dd,
				_elm_lang$core$Basics$toString(f));
			var h = _myrho$elm_round$Round$truncate(fl) + (_elm_lang$core$Native_Utils.eq(f - (e * n), e * n) ? ((_elm_lang$core$Native_Utils.cmp(fl, 0) < 0) ? -1 : 1) : 0);
			var j = _elm_lang$core$Basics$toString(h);
			var i = (_elm_lang$core$Native_Utils.eq(j, '0') && ((!_elm_lang$core$Native_Utils.eq(f - (e * n), 0)) && ((_elm_lang$core$Native_Utils.cmp(fl, 0) < 0) && (_elm_lang$core$Native_Utils.cmp(fl, -1) > 0)))) ? A2(_elm_lang$core$Basics_ops['++'], '-', j) : j;
			return A2(
				_elm_lang$core$Basics_ops['++'],
				i,
				A2(_elm_lang$core$Basics_ops['++'], '.', g));
		}
	});
var _myrho$elm_round$Round$round = _myrho$elm_round$Round$roundFun(_elm_lang$core$Basics$round);
var _myrho$elm_round$Round$roundNum = _myrho$elm_round$Round$funNum(_myrho$elm_round$Round$round);
var _myrho$elm_round$Round$ceiling = _myrho$elm_round$Round$roundFun(_elm_lang$core$Basics$ceiling);
var _myrho$elm_round$Round$ceilingNum = _myrho$elm_round$Round$funNum(_myrho$elm_round$Round$ceiling);
var _myrho$elm_round$Round$floor = _myrho$elm_round$Round$roundFun(_elm_lang$core$Basics$floor);
var _myrho$elm_round$Round$floorCom = F2(
	function (s, fl) {
		return (_elm_lang$core$Native_Utils.cmp(fl, 0) < 0) ? A2(_myrho$elm_round$Round$ceiling, s, fl) : A2(_myrho$elm_round$Round$floor, s, fl);
	});
var _myrho$elm_round$Round$floorNumCom = _myrho$elm_round$Round$funNum(_myrho$elm_round$Round$floorCom);
var _myrho$elm_round$Round$ceilingCom = F2(
	function (s, fl) {
		return (_elm_lang$core$Native_Utils.cmp(fl, 0) < 0) ? A2(_myrho$elm_round$Round$floor, s, fl) : A2(_myrho$elm_round$Round$ceiling, s, fl);
	});
var _myrho$elm_round$Round$ceilingNumCom = _myrho$elm_round$Round$funNum(_myrho$elm_round$Round$ceilingCom);
var _myrho$elm_round$Round$floorNum = _myrho$elm_round$Round$funNum(_myrho$elm_round$Round$floor);
var _myrho$elm_round$Round$roundCom = _myrho$elm_round$Round$roundFun(
	function (fl) {
		var dec = fl - _elm_lang$core$Basics$toFloat(
			_myrho$elm_round$Round$truncate(fl));
		return (_elm_lang$core$Native_Utils.cmp(dec, 0.5) > -1) ? _elm_lang$core$Basics$ceiling(fl) : ((_elm_lang$core$Native_Utils.cmp(dec, -0.5) < 1) ? _elm_lang$core$Basics$floor(fl) : _elm_lang$core$Basics$round(fl));
	});
var _myrho$elm_round$Round$roundNumCom = _myrho$elm_round$Round$funNum(_myrho$elm_round$Round$roundCom);

var _terezka$elm_plot$Plot_Types$HintInfo = F2(
	function (a, b) {
		return {xValue: a, yValues: b};
	});

var _terezka$elm_plot$Internal_Types$Edges = F2(
	function (a, b) {
		return {lower: a, upper: b};
	});
var _terezka$elm_plot$Internal_Types$EdgesAny = F2(
	function (a, b) {
		return {lower: a, upper: b};
	});
var _terezka$elm_plot$Internal_Types$Oriented = F2(
	function (a, b) {
		return {x: a, y: b};
	});
var _terezka$elm_plot$Internal_Types$Meta = function (a) {
	return function (b) {
		return function (c) {
			return function (d) {
				return function (e) {
					return function (f) {
						return function (g) {
							return function (h) {
								return function (i) {
									return function (j) {
										return function (k) {
											return {scale: a, ticks: b, toSvgCoords: c, fromSvgCoords: d, oppositeTicks: e, oppositeToSvgCoords: f, axisCrossings: g, oppositeAxisCrossings: h, getHintInfo: i, toNearestX: j, id: k};
										};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var _terezka$elm_plot$Internal_Types$Scale = F5(
	function (a, b, c, d, e) {
		return {range: a, lowest: b, highest: c, length: d, offset: e};
	});
var _terezka$elm_plot$Internal_Types$HintInfo = F2(
	function (a, b) {
		return {xValue: a, yValues: b};
	});
var _terezka$elm_plot$Internal_Types$Y = {ctor: 'Y'};
var _terezka$elm_plot$Internal_Types$X = {ctor: 'X'};
var _terezka$elm_plot$Internal_Types$Bezier = {ctor: 'Bezier'};
var _terezka$elm_plot$Internal_Types$None = {ctor: 'None'};
var _terezka$elm_plot$Internal_Types$Outer = {ctor: 'Outer'};
var _terezka$elm_plot$Internal_Types$Inner = {ctor: 'Inner'};
var _terezka$elm_plot$Internal_Types$Percentage = function (a) {
	return {ctor: 'Percentage', _0: a};
};
var _terezka$elm_plot$Internal_Types$Fixed = function (a) {
	return {ctor: 'Fixed', _0: a};
};

var _terezka$elm_plot$Internal_Stuff$shareTo = F3(
	function (shared, toB, toC) {
		return A2(
			toC,
			shared,
			toB(shared));
	});
var _terezka$elm_plot$Internal_Stuff$foldOriented = F3(
	function (fold, orientation, old) {
		var _p0 = orientation;
		if (_p0.ctor === 'X') {
			return _elm_lang$core$Native_Utils.update(
				old,
				{
					x: fold(old.x)
				});
		} else {
			return _elm_lang$core$Native_Utils.update(
				old,
				{
					y: fold(old.y)
				});
		}
	});
var _terezka$elm_plot$Internal_Stuff$flipOriented = function (_p1) {
	var _p2 = _p1;
	return {x: _p2.y, y: _p2.x};
};
var _terezka$elm_plot$Internal_Stuff_ops = _terezka$elm_plot$Internal_Stuff_ops || {};
_terezka$elm_plot$Internal_Stuff_ops['?'] = F3(
	function (orientation, x, y) {
		var _p3 = orientation;
		if (_p3.ctor === 'X') {
			return x;
		} else {
			return y;
		}
	});
var _terezka$elm_plot$Internal_Stuff$getValues = function (orientation) {
	var toValue = A3(
		F2(
			function (x, y) {
				return A2(_terezka$elm_plot$Internal_Stuff_ops['?'], x, y);
			}),
		orientation,
		_elm_lang$core$Tuple$first,
		_elm_lang$core$Tuple$second);
	return _elm_lang$core$List$map(toValue);
};
var _terezka$elm_plot$Internal_Stuff$getDifference = F2(
	function (a, b) {
		return _elm_lang$core$Basics$abs(a - b);
	});
var _terezka$elm_plot$Internal_Stuff$getClosest = F3(
	function (value, candidate, closest) {
		var _p4 = closest;
		if (_p4.ctor === 'Just') {
			var _p5 = _p4._0;
			return (_elm_lang$core$Native_Utils.cmp(
				A2(_terezka$elm_plot$Internal_Stuff$getDifference, value, candidate),
				A2(_terezka$elm_plot$Internal_Stuff$getDifference, value, _p5)) < 0) ? _elm_lang$core$Maybe$Just(candidate) : _elm_lang$core$Maybe$Just(_p5);
		} else {
			return _elm_lang$core$Maybe$Just(candidate);
		}
	});
var _terezka$elm_plot$Internal_Stuff$toNearest = F2(
	function (values, value) {
		return A3(
			_elm_lang$core$List$foldr,
			_terezka$elm_plot$Internal_Stuff$getClosest(value),
			_elm_lang$core$Maybe$Nothing,
			values);
	});
var _terezka$elm_plot$Internal_Stuff$ceilToNearest = F2(
	function (precision, value) {
		return _elm_lang$core$Basics$toFloat(
			_elm_lang$core$Basics$ceiling(value / precision)) * precision;
	});
var _terezka$elm_plot$Internal_Stuff$pixelsToValue = F3(
	function (length, range, pixels) {
		return (range * pixels) / length;
	});
var _terezka$elm_plot$Internal_Stuff$foldBounds = F2(
	function (oldBounds, newBounds) {
		var _p6 = oldBounds;
		if (_p6.ctor === 'Just') {
			var _p7 = _p6._0;
			return {
				lower: A2(_elm_lang$core$Basics$min, _p7.lower, newBounds.lower),
				upper: A2(_elm_lang$core$Basics$max, _p7.upper, newBounds.upper)
			};
		} else {
			return newBounds;
		}
	});
var _terezka$elm_plot$Internal_Stuff$getRange = F2(
	function (lowest, highest) {
		return (_elm_lang$core$Native_Utils.cmp(highest - lowest, 0) > 0) ? (highest - lowest) : 1;
	});
var _terezka$elm_plot$Internal_Stuff$getLowest = function (values) {
	return A2(
		_elm_lang$core$Maybe$withDefault,
		0,
		_elm_lang$core$List$minimum(values));
};
var _terezka$elm_plot$Internal_Stuff$getHighest = function (values) {
	return A2(
		_elm_lang$core$Maybe$withDefault,
		10,
		_elm_lang$core$List$maximum(values));
};
var _terezka$elm_plot$Internal_Stuff$getEdges = function (range) {
	return {
		ctor: '_Tuple2',
		_0: _terezka$elm_plot$Internal_Stuff$getLowest(range),
		_1: _terezka$elm_plot$Internal_Stuff$getHighest(range)
	};
};
var _terezka$elm_plot$Internal_Stuff$getEdgesX = function (points) {
	return _terezka$elm_plot$Internal_Stuff$getEdges(
		A2(_elm_lang$core$List$map, _elm_lang$core$Tuple$first, points));
};
var _terezka$elm_plot$Internal_Stuff$getEdgesY = function (points) {
	return _terezka$elm_plot$Internal_Stuff$getEdges(
		A2(_elm_lang$core$List$map, _elm_lang$core$Tuple$second, points));
};

var _terezka$elm_plot$Internal_Draw$addDisplacement = F2(
	function (_p1, _p0) {
		var _p2 = _p1;
		var _p3 = _p0;
		return {ctor: '_Tuple2', _0: _p2._0 + _p3._0, _1: _p2._1 + _p3._1};
	});
var _terezka$elm_plot$Internal_Draw$toPixels = function (pixels) {
	return A2(
		_elm_lang$core$Basics_ops['++'],
		_elm_lang$core$Basics$toString(pixels),
		'px');
};
var _terezka$elm_plot$Internal_Draw$toPixelsInt = function (_p4) {
	return _terezka$elm_plot$Internal_Draw$toPixels(
		_elm_lang$core$Basics$toFloat(_p4));
};
var _terezka$elm_plot$Internal_Draw$toStyle = function (styles) {
	return A3(
		_elm_lang$core$List$foldr,
		F2(
			function (_p5, r) {
				var _p6 = _p5;
				return A2(
					_elm_lang$core$Basics_ops['++'],
					r,
					A2(
						_elm_lang$core$Basics_ops['++'],
						_p6._0,
						A2(
							_elm_lang$core$Basics_ops['++'],
							':',
							A2(_elm_lang$core$Basics_ops['++'], _p6._1, '; '))));
			}),
		'',
		styles);
};
var _terezka$elm_plot$Internal_Draw$toRotate = F3(
	function (d, x, y) {
		return A2(
			_elm_lang$core$Basics_ops['++'],
			'rotate(',
			A2(
				_elm_lang$core$Basics_ops['++'],
				_elm_lang$core$Basics$toString(d),
				A2(
					_elm_lang$core$Basics_ops['++'],
					' ',
					A2(
						_elm_lang$core$Basics_ops['++'],
						_elm_lang$core$Basics$toString(x),
						A2(
							_elm_lang$core$Basics_ops['++'],
							' ',
							A2(
								_elm_lang$core$Basics_ops['++'],
								_elm_lang$core$Basics$toString(y),
								')'))))));
	});
var _terezka$elm_plot$Internal_Draw$toTranslate = function (_p7) {
	var _p8 = _p7;
	return A2(
		_elm_lang$core$Basics_ops['++'],
		'translate(',
		A2(
			_elm_lang$core$Basics_ops['++'],
			_elm_lang$core$Basics$toString(_p8._0),
			A2(
				_elm_lang$core$Basics_ops['++'],
				',',
				A2(
					_elm_lang$core$Basics_ops['++'],
					_elm_lang$core$Basics$toString(_p8._1),
					')'))));
};
var _terezka$elm_plot$Internal_Draw$magnitude = 0.5;
var _terezka$elm_plot$Internal_Draw$toBezierPoints = F3(
	function (_p11, _p10, _p9) {
		var _p12 = _p11;
		var _p13 = _p10;
		var _p16 = _p13._1;
		var _p15 = _p13._0;
		var _p14 = _p9;
		var dy = _p14._1 - _p12._1;
		var dx = _p14._0 - _p12._0;
		return {
			ctor: '::',
			_0: {ctor: '_Tuple2', _0: _p15 - ((dx / 2) * _terezka$elm_plot$Internal_Draw$magnitude), _1: _p16 - ((dy / 2) * _terezka$elm_plot$Internal_Draw$magnitude)},
			_1: {
				ctor: '::',
				_0: {ctor: '_Tuple2', _0: _p15, _1: _p16},
				_1: {ctor: '[]'}
			}
		};
	});
var _terezka$elm_plot$Internal_Draw$coordsToSmoothBezierCoords = function (coords) {
	var last = A2(
		_elm_lang$core$Maybe$withDefault,
		{ctor: '_Tuple2', _0: 0, _1: 0},
		_elm_lang$core$List$head(
			_elm_lang$core$List$reverse(coords)));
	var lefts = A2(
		_elm_lang$core$Basics_ops['++'],
		coords,
		{
			ctor: '::',
			_0: last,
			_1: {ctor: '[]'}
		});
	var middles = A2(
		_elm_lang$core$Maybe$withDefault,
		{ctor: '[]'},
		_elm_lang$core$List$tail(lefts));
	var rights = A2(
		_elm_lang$core$Maybe$withDefault,
		{ctor: '[]'},
		_elm_lang$core$List$tail(middles));
	return A4(_elm_lang$core$List$map3, _terezka$elm_plot$Internal_Draw$toBezierPoints, lefts, middles, rights);
};
var _terezka$elm_plot$Internal_Draw$toInstruction = F2(
	function (instructionType, coords) {
		var coordsString = A2(
			_elm_lang$core$String$join,
			',',
			A2(_elm_lang$core$List$map, _elm_lang$core$Basics$toString, coords));
		return A2(
			_elm_lang$core$Basics_ops['++'],
			instructionType,
			A2(_elm_lang$core$Basics_ops['++'], ' ', coordsString));
	});
var _terezka$elm_plot$Internal_Draw$coordsToInstruction = F2(
	function (instructionType, coords) {
		return A2(
			_elm_lang$core$String$join,
			'',
			A2(
				_elm_lang$core$List$map,
				function (_p17) {
					var _p18 = _p17;
					return A2(
						_terezka$elm_plot$Internal_Draw$toInstruction,
						instructionType,
						{
							ctor: '::',
							_0: _p18._0,
							_1: {
								ctor: '::',
								_0: _p18._1,
								_1: {ctor: '[]'}
							}
						});
				},
				coords));
	});
var _terezka$elm_plot$Internal_Draw$coordsListToInstruction = F2(
	function (instructionType, coords) {
		return A2(
			_elm_lang$core$String$join,
			'',
			A2(
				_elm_lang$core$List$map,
				function (points) {
					return A2(
						_terezka$elm_plot$Internal_Draw$toInstruction,
						instructionType,
						A3(
							_elm_lang$core$List$foldr,
							F2(
								function (_p19, all) {
									var _p20 = _p19;
									return A2(
										_elm_lang$core$Basics_ops['++'],
										{
											ctor: '::',
											_0: _p20._0,
											_1: {
												ctor: '::',
												_0: _p20._1,
												_1: {ctor: '[]'}
											}
										},
										all);
								}),
							{ctor: '[]'},
							points));
				},
				coords));
	});
var _terezka$elm_plot$Internal_Draw$toLineInstructions = function (smoothing) {
	var _p21 = smoothing;
	if (_p21.ctor === 'None') {
		return _terezka$elm_plot$Internal_Draw$coordsToInstruction('L');
	} else {
		return function (_p22) {
			return A2(
				_terezka$elm_plot$Internal_Draw$coordsListToInstruction,
				'S',
				_terezka$elm_plot$Internal_Draw$coordsToSmoothBezierCoords(_p22));
		};
	}
};
var _terezka$elm_plot$Internal_Draw$startPath = function (data) {
	var tail = A2(
		_elm_lang$core$Maybe$withDefault,
		{ctor: '[]'},
		_elm_lang$core$List$tail(data));
	var _p23 = A2(
		_elm_lang$core$Maybe$withDefault,
		{ctor: '_Tuple2', _0: 0, _1: 0},
		_elm_lang$core$List$head(data));
	var x = _p23._0;
	var y = _p23._1;
	return {
		ctor: '_Tuple2',
		_0: A2(
			_terezka$elm_plot$Internal_Draw$toInstruction,
			'M',
			{
				ctor: '::',
				_0: x,
				_1: {
					ctor: '::',
					_0: y,
					_1: {ctor: '[]'}
				}
			}),
		_1: tail
	};
};
var _terezka$elm_plot$Internal_Draw$classBase = function (base) {
	return A2(_elm_lang$core$Basics_ops['++'], 'elm-plot__', base);
};
var _terezka$elm_plot$Internal_Draw$classAttribute = F2(
	function (base, classes) {
		return _elm_lang$svg$Svg_Attributes$class(
			A2(
				_elm_lang$core$String$join,
				' ',
				{
					ctor: '::',
					_0: _terezka$elm_plot$Internal_Draw$classBase(base),
					_1: classes
				}));
	});
var _terezka$elm_plot$Internal_Draw$classAttributeOriented = F3(
	function (base, orientation, classes) {
		return A2(
			_terezka$elm_plot$Internal_Draw$classAttribute,
			base,
			{
				ctor: '::',
				_0: A3(
					F2(
						function (x, y) {
							return A2(_terezka$elm_plot$Internal_Stuff_ops['?'], x, y);
						}),
					orientation,
					A2(
						_elm_lang$core$Basics_ops['++'],
						_terezka$elm_plot$Internal_Draw$classBase(base),
						'--x'),
					A2(
						_elm_lang$core$Basics_ops['++'],
						_terezka$elm_plot$Internal_Draw$classBase(base),
						'--y')),
				_1: classes
			});
	});
var _terezka$elm_plot$Internal_Draw$positionAttributes = F2(
	function (_p25, _p24) {
		var _p26 = _p25;
		var _p27 = _p24;
		return {
			ctor: '::',
			_0: _elm_lang$svg$Svg_Attributes$x1(
				_elm_lang$core$Basics$toString(_p26._0)),
			_1: {
				ctor: '::',
				_0: _elm_lang$svg$Svg_Attributes$y1(
					_elm_lang$core$Basics$toString(_p26._1)),
				_1: {
					ctor: '::',
					_0: _elm_lang$svg$Svg_Attributes$x2(
						_elm_lang$core$Basics$toString(_p27._0)),
					_1: {
						ctor: '::',
						_0: _elm_lang$svg$Svg_Attributes$y2(
							_elm_lang$core$Basics$toString(_p27._1)),
						_1: {ctor: '[]'}
					}
				}
			}
		};
	});
var _terezka$elm_plot$Internal_Draw$fullLine = F3(
	function (attributes, _p28, value) {
		var _p29 = _p28;
		var _p31 = _p29.toSvgCoords;
		var _p30 = _p29.scale.x;
		var lowest = _p30.lowest;
		var highest = _p30.highest;
		var begin = _p31(
			{ctor: '_Tuple2', _0: lowest, _1: value});
		var end = _p31(
			{ctor: '_Tuple2', _0: highest, _1: value});
		return A2(
			_elm_lang$svg$Svg$line,
			A2(
				_elm_lang$core$Basics_ops['++'],
				A2(_terezka$elm_plot$Internal_Draw$positionAttributes, begin, end),
				attributes),
			{ctor: '[]'});
	});

var _terezka$elm_plot$Internal_Tick$defaultView = F3(
	function (_p1, orientation, _p0) {
		var _p2 = _p1;
		var styleFinal = A2(
			_elm_lang$core$Basics_ops['++'],
			_p2.style,
			{
				ctor: '::',
				_0: {
					ctor: '_Tuple2',
					_0: 'stroke-width',
					_1: _terezka$elm_plot$Internal_Draw$toPixelsInt(_p2.width)
				},
				_1: {ctor: '[]'}
			});
		var attrs = A2(
			_elm_lang$core$Basics_ops['++'],
			{
				ctor: '::',
				_0: _elm_lang$svg$Svg_Attributes$style(
					_terezka$elm_plot$Internal_Draw$toStyle(styleFinal)),
				_1: {
					ctor: '::',
					_0: _elm_lang$svg$Svg_Attributes$y2(
						_elm_lang$core$Basics$toString(_p2.length)),
					_1: {
						ctor: '::',
						_0: _elm_lang$svg$Svg_Attributes$class(
							A2(
								_elm_lang$core$String$join,
								' ',
								{ctor: '::', _0: 'elm-plot__tick__default-view', _1: _p2.classes})),
						_1: {ctor: '[]'}
					}
				}
			},
			_p2.customAttrs);
		return A2(
			_elm_lang$svg$Svg$line,
			attrs,
			{ctor: '[]'});
	});
var _terezka$elm_plot$Internal_Tick$toViewFromStyleDynamic = F3(
	function (toStyleConfig, orientation, info) {
		return A3(
			_terezka$elm_plot$Internal_Tick$defaultView,
			toStyleConfig(info),
			orientation,
			info);
	});
var _terezka$elm_plot$Internal_Tick$toView = function (_p3) {
	var _p4 = _p3;
	var _p5 = _p4.viewConfig;
	switch (_p5.ctor) {
		case 'FromStyle':
			return _terezka$elm_plot$Internal_Tick$defaultView(_p5._0);
		case 'FromStyleDynamic':
			return _terezka$elm_plot$Internal_Tick$toViewFromStyleDynamic(_p5._0);
		default:
			return _p5._0;
	}
};
var _terezka$elm_plot$Internal_Tick$defaultStyleConfig = {
	length: 7,
	width: 1,
	style: {ctor: '[]'},
	classes: {ctor: '[]'},
	customAttrs: {ctor: '[]'}
};
var _terezka$elm_plot$Internal_Tick$Config = function (a) {
	return {viewConfig: a};
};
var _terezka$elm_plot$Internal_Tick$StyleConfig = F5(
	function (a, b, c, d, e) {
		return {length: a, width: b, style: c, classes: d, customAttrs: e};
	});
var _terezka$elm_plot$Internal_Tick$FromCustomView = function (a) {
	return {ctor: 'FromCustomView', _0: a};
};
var _terezka$elm_plot$Internal_Tick$FromStyleDynamic = function (a) {
	return {ctor: 'FromStyleDynamic', _0: a};
};
var _terezka$elm_plot$Internal_Tick$FromStyle = function (a) {
	return {ctor: 'FromStyle', _0: a};
};
var _terezka$elm_plot$Internal_Tick$defaultConfig = {
	viewConfig: _terezka$elm_plot$Internal_Tick$FromStyle(_terezka$elm_plot$Internal_Tick$defaultStyleConfig)
};

var _terezka$elm_plot$Internal_Label$defaultView = F2(
	function (_p0, text) {
		var _p1 = _p0;
		var _p2 = A2(
			_elm_lang$core$Maybe$withDefault,
			{ctor: '_Tuple2', _0: 0, _1: 0},
			_p1.displace);
		var dx = _p2._0;
		var dy = _p2._1;
		var attrs = A2(
			_elm_lang$core$Basics_ops['++'],
			{
				ctor: '::',
				_0: _elm_lang$svg$Svg_Attributes$transform(
					_terezka$elm_plot$Internal_Draw$toTranslate(
						{
							ctor: '_Tuple2',
							_0: _elm_lang$core$Basics$toFloat(dx),
							_1: _elm_lang$core$Basics$toFloat(dy)
						})),
				_1: {
					ctor: '::',
					_0: _elm_lang$svg$Svg_Attributes$style(
						_terezka$elm_plot$Internal_Draw$toStyle(_p1.style)),
					_1: {
						ctor: '::',
						_0: _elm_lang$svg$Svg_Attributes$class(
							A2(
								_elm_lang$core$String$join,
								' ',
								{ctor: '::', _0: 'elm-plot__label__default-view', _1: _p1.classes})),
						_1: {ctor: '[]'}
					}
				}
			},
			_p1.customAttrs);
		return A2(
			_elm_lang$svg$Svg$text_,
			attrs,
			{
				ctor: '::',
				_0: A2(
					_elm_lang$svg$Svg$tspan,
					{ctor: '[]'},
					{
						ctor: '::',
						_0: _elm_lang$svg$Svg$text(text),
						_1: {ctor: '[]'}
					}),
				_1: {ctor: '[]'}
			});
	});
var _terezka$elm_plot$Internal_Label$viewLabels = F3(
	function (config, view, infos) {
		var _p3 = config.format;
		if (_p3.ctor === 'FromFunc') {
			return A2(
				_elm_lang$core$List$map,
				function (info) {
					return A2(
						view,
						info,
						_p3._0(info));
				},
				infos);
		} else {
			return A3(_elm_lang$core$List$map2, view, infos, _p3._0);
		}
	});
var _terezka$elm_plot$Internal_Label$view = F3(
	function (config, toAttributes, infos) {
		var _p4 = config.viewConfig;
		switch (_p4.ctor) {
			case 'FromStyle':
				return A3(
					_terezka$elm_plot$Internal_Label$viewLabels,
					config,
					F2(
						function (info, text) {
							return A2(
								_elm_lang$svg$Svg$g,
								toAttributes(info),
								{
									ctor: '::',
									_0: A2(_terezka$elm_plot$Internal_Label$defaultView, _p4._0, text),
									_1: {ctor: '[]'}
								});
						}),
					infos);
			case 'FromStyleDynamic':
				return A3(
					_terezka$elm_plot$Internal_Label$viewLabels,
					config,
					F2(
						function (info, text) {
							return A2(
								_elm_lang$svg$Svg$g,
								toAttributes(info),
								{
									ctor: '::',
									_0: A2(
										_terezka$elm_plot$Internal_Label$defaultView,
										_p4._0(info),
										text),
									_1: {ctor: '[]'}
								});
						}),
					infos);
			default:
				return A2(
					_elm_lang$core$List$map,
					function (info) {
						return A2(
							_elm_lang$svg$Svg$g,
							toAttributes(info),
							{
								ctor: '::',
								_0: _p4._0(info),
								_1: {ctor: '[]'}
							});
					},
					infos);
		}
	});
var _terezka$elm_plot$Internal_Label$defaultStyleConfig = {
	displace: _elm_lang$core$Maybe$Nothing,
	style: {ctor: '[]'},
	classes: {ctor: '[]'},
	customAttrs: {ctor: '[]'}
};
var _terezka$elm_plot$Internal_Label$Config = F2(
	function (a, b) {
		return {viewConfig: a, format: b};
	});
var _terezka$elm_plot$Internal_Label$StyleConfig = F4(
	function (a, b, c, d) {
		return {displace: a, style: b, classes: c, customAttrs: d};
	});
var _terezka$elm_plot$Internal_Label$FromList = function (a) {
	return {ctor: 'FromList', _0: a};
};
var _terezka$elm_plot$Internal_Label$FromFunc = function (a) {
	return {ctor: 'FromFunc', _0: a};
};
var _terezka$elm_plot$Internal_Label$FromCustomView = function (a) {
	return {ctor: 'FromCustomView', _0: a};
};
var _terezka$elm_plot$Internal_Label$FromStyleDynamic = function (a) {
	return {ctor: 'FromStyleDynamic', _0: a};
};
var _terezka$elm_plot$Internal_Label$FromStyle = function (a) {
	return {ctor: 'FromStyle', _0: a};
};
var _terezka$elm_plot$Internal_Label$defaultConfig = {
	viewConfig: _terezka$elm_plot$Internal_Label$FromStyle(_terezka$elm_plot$Internal_Label$defaultStyleConfig),
	format: _terezka$elm_plot$Internal_Label$FromFunc(
		_elm_lang$core$Basics$always(''))
};
var _terezka$elm_plot$Internal_Label$toDefaultConfig = function (format) {
	return {
		viewConfig: _terezka$elm_plot$Internal_Label$FromStyle(_terezka$elm_plot$Internal_Label$defaultStyleConfig),
		format: _terezka$elm_plot$Internal_Label$FromFunc(format)
	};
};

var _terezka$elm_plot$Internal_Line$stdAttributes = F2(
	function (d, style) {
		return {
			ctor: '::',
			_0: _elm_lang$svg$Svg_Attributes$d(d),
			_1: {
				ctor: '::',
				_0: _elm_lang$svg$Svg_Attributes$style(
					_terezka$elm_plot$Internal_Draw$toStyle(style)),
				_1: {
					ctor: '::',
					_0: _elm_lang$svg$Svg_Attributes$class('elm-plot__serie--line'),
					_1: {ctor: '[]'}
				}
			}
		};
	});
var _terezka$elm_plot$Internal_Line$view = F3(
	function (_p1, _p0, points) {
		var _p2 = _p1;
		var _p3 = _p0;
		var svgPoints = A2(_elm_lang$core$List$map, _p2.toSvgCoords, points);
		var _p4 = _terezka$elm_plot$Internal_Draw$startPath(svgPoints);
		var startInstruction = _p4._0;
		var instructions = A2(_terezka$elm_plot$Internal_Draw$toLineInstructions, _p3.smoothing, svgPoints);
		var attrs = A2(
			_elm_lang$core$Basics_ops['++'],
			A2(
				_terezka$elm_plot$Internal_Line$stdAttributes,
				A2(_elm_lang$core$Basics_ops['++'], startInstruction, instructions),
				_p3.style),
			_p3.customAttrs);
		return A2(
			_elm_lang$svg$Svg$path,
			attrs,
			{ctor: '[]'});
	});
var _terezka$elm_plot$Internal_Line$defaultConfig = {
	style: {
		ctor: '::',
		_0: {ctor: '_Tuple2', _0: 'fill', _1: 'transparent'},
		_1: {
			ctor: '::',
			_0: {ctor: '_Tuple2', _0: 'stroke', _1: 'black'},
			_1: {ctor: '[]'}
		}
	},
	smoothing: _terezka$elm_plot$Internal_Types$None,
	customAttrs: {ctor: '[]'}
};
var _terezka$elm_plot$Internal_Line$Config = F3(
	function (a, b, c) {
		return {style: a, smoothing: b, customAttrs: c};
	});

var _terezka$elm_plot$Internal_Axis$zipWithDistance = F4(
	function (hasZero, lowerThanZero, index, value) {
		var distance = _elm_lang$core$Native_Utils.eq(value, 0) ? 0 : (((_elm_lang$core$Native_Utils.cmp(value, 0) > 0) && hasZero) ? (index - lowerThanZero) : ((_elm_lang$core$Native_Utils.cmp(value, 0) > 0) ? ((index - lowerThanZero) + 1) : (lowerThanZero - index)));
		return {index: distance, value: value};
	});
var _terezka$elm_plot$Internal_Axis$toIndexInfo = function (values) {
	var hasZero = A2(
		_elm_lang$core$List$any,
		function (v) {
			return _elm_lang$core$Native_Utils.eq(v, 0);
		},
		values);
	var lowerThanZero = _elm_lang$core$List$length(
		A2(
			_elm_lang$core$List$filter,
			function (v) {
				return _elm_lang$core$Native_Utils.cmp(v, 0) < 0;
			},
			values));
	return A2(
		_elm_lang$core$List$indexedMap,
		A2(_terezka$elm_plot$Internal_Axis$zipWithDistance, hasZero, lowerThanZero),
		values);
};
var _terezka$elm_plot$Internal_Axis$getDelta = F2(
	function (range, totalTicks) {
		var delta0 = range / _elm_lang$core$Basics$toFloat(totalTicks);
		var mag = _elm_lang$core$Basics$floor(
			A2(_elm_lang$core$Basics$logBase, 10, delta0));
		var magPow = _elm_lang$core$Basics$toFloat(
			Math.pow(10, mag));
		var magMsd = _elm_lang$core$Basics$round(delta0 / magPow);
		var magMsdFinal = (_elm_lang$core$Native_Utils.cmp(magMsd, 5) > 0) ? 10 : ((_elm_lang$core$Native_Utils.cmp(magMsd, 2) > 0) ? 5 : ((_elm_lang$core$Native_Utils.cmp(magMsd, 1) > 0) ? 1 : magMsd));
		return _elm_lang$core$Basics$toFloat(magMsdFinal) * magPow;
	});
var _terezka$elm_plot$Internal_Axis$getDeltaPrecision = function (delta) {
	return _elm_lang$core$Basics$abs(
		A2(
			_elm_lang$core$Basics$min,
			0,
			A2(
				F2(
					function (x, y) {
						return x - y;
					}),
				1,
				_elm_lang$core$String$length(
					A2(
						_elm_lang$core$Maybe$withDefault,
						'',
						_elm_lang$core$List$head(
							A2(
								_elm_lang$core$List$map,
								function (_) {
									return _.match;
								},
								A3(
									_elm_lang$core$Regex$find,
									_elm_lang$core$Regex$AtMost(1),
									_elm_lang$core$Regex$regex('\\.[0-9]*'),
									_elm_lang$core$Basics$toString(delta)))))))));
};
var _terezka$elm_plot$Internal_Axis$toValue = F3(
	function (delta, firstValue, index) {
		return A2(
			_elm_lang$core$Result$withDefault,
			0,
			_elm_lang$core$String$toFloat(
				A2(
					_myrho$elm_round$Round$round,
					_terezka$elm_plot$Internal_Axis$getDeltaPrecision(delta),
					firstValue + (_elm_lang$core$Basics$toFloat(index) * delta))));
	});
var _terezka$elm_plot$Internal_Axis$getCount = F4(
	function (delta, lowest, range, firstValue) {
		return _elm_lang$core$Basics$floor(
			(range - (_elm_lang$core$Basics$abs(lowest) - _elm_lang$core$Basics$abs(firstValue))) / delta);
	});
var _terezka$elm_plot$Internal_Axis$getFirstValue = F2(
	function (delta, lowest) {
		return A2(_terezka$elm_plot$Internal_Stuff$ceilToNearest, delta, lowest);
	});
var _terezka$elm_plot$Internal_Axis$toValuesFromDelta = F2(
	function (delta, _p0) {
		var _p1 = _p0;
		var _p2 = _p1.lowest;
		var firstValue = A2(_terezka$elm_plot$Internal_Axis$getFirstValue, delta, _p2);
		var tickCount = A4(_terezka$elm_plot$Internal_Axis$getCount, delta, _p2, _p1.range, firstValue);
		return A2(
			_elm_lang$core$List$map,
			A2(_terezka$elm_plot$Internal_Axis$toValue, delta, firstValue),
			A2(_elm_lang$core$List$range, 0, tickCount));
	});
var _terezka$elm_plot$Internal_Axis$toValuesFromCount = F2(
	function (appxCount, scale) {
		return A2(
			_terezka$elm_plot$Internal_Axis$toValuesFromDelta,
			A2(_terezka$elm_plot$Internal_Axis$getDelta, scale.range, appxCount),
			scale);
	});
var _terezka$elm_plot$Internal_Axis$toValuesAuto = _terezka$elm_plot$Internal_Axis$toValuesFromCount(10);
var _terezka$elm_plot$Internal_Axis$getValues = function (config) {
	var _p3 = config;
	switch (_p3.ctor) {
		case 'AutoValues':
			return _terezka$elm_plot$Internal_Axis$toValuesAuto;
		case 'FromDelta':
			return _terezka$elm_plot$Internal_Axis$toValuesFromDelta(_p3._0);
		case 'FromCount':
			return _terezka$elm_plot$Internal_Axis$toValuesFromCount(_p3._0);
		default:
			return _elm_lang$core$Basics$always(_p3._0);
	}
};
var _terezka$elm_plot$Internal_Axis$toLabelValues = F2(
	function (config, tickValues) {
		return A2(_elm_lang$core$Maybe$withDefault, tickValues, config.labelValues);
	});
var _terezka$elm_plot$Internal_Axis$isCrossing = F2(
	function (crossings, value) {
		return !A2(_elm_lang$core$List$member, value, crossings);
	});
var _terezka$elm_plot$Internal_Axis$filterValues = F3(
	function (meta, config, values) {
		return config.cleanCrossings ? A2(
			_elm_lang$core$List$filter,
			_terezka$elm_plot$Internal_Axis$isCrossing(meta.oppositeAxisCrossings),
			values) : values;
	});
var _terezka$elm_plot$Internal_Axis$toTickValues = F2(
	function (meta, config) {
		return A3(
			_terezka$elm_plot$Internal_Axis$filterValues,
			meta,
			config,
			A2(_terezka$elm_plot$Internal_Axis$getValues, config.tickValues, meta.scale.x));
	});
var _terezka$elm_plot$Internal_Axis$toRotate = F2(
	function (anchor, orientation) {
		var _p4 = orientation;
		if (_p4.ctor === 'X') {
			var _p5 = anchor;
			if (_p5.ctor === 'Inner') {
				return 'rotate(180 0 0)';
			} else {
				return 'rotate(0 0 0)';
			}
		} else {
			var _p6 = anchor;
			if (_p6.ctor === 'Inner') {
				return 'rotate(-90 0 0)';
			} else {
				return 'rotate(90 0 0)';
			}
		}
	});
var _terezka$elm_plot$Internal_Axis$getDisplacement = F2(
	function (anchor, orientation) {
		var _p7 = orientation;
		if (_p7.ctor === 'X') {
			var _p8 = anchor;
			if (_p8.ctor === 'Inner') {
				return {ctor: '_Tuple2', _0: 0, _1: -15};
			} else {
				return {ctor: '_Tuple2', _0: 0, _1: 25};
			}
		} else {
			var _p9 = anchor;
			if (_p9.ctor === 'Inner') {
				return {ctor: '_Tuple2', _0: 10, _1: 5};
			} else {
				return {ctor: '_Tuple2', _0: -10, _1: 5};
			}
		}
	});
var _terezka$elm_plot$Internal_Axis$getYAnchorStyle = function (anchor) {
	var _p10 = anchor;
	if (_p10.ctor === 'Inner') {
		return 'start';
	} else {
		return 'end';
	}
};
var _terezka$elm_plot$Internal_Axis$toAnchorStyle = F2(
	function (anchor, orientation) {
		var _p11 = orientation;
		if (_p11.ctor === 'X') {
			return 'text-anchor: middle;';
		} else {
			return A2(
				_elm_lang$core$Basics_ops['++'],
				'text-anchor:',
				A2(
					_elm_lang$core$Basics_ops['++'],
					_terezka$elm_plot$Internal_Axis$getYAnchorStyle(anchor),
					';'));
		}
	});
var _terezka$elm_plot$Internal_Axis$getAxisPosition = F2(
	function (_p12, position) {
		var _p13 = _p12;
		var _p16 = _p13.lowest;
		var _p15 = _p13.highest;
		var _p14 = position;
		switch (_p14.ctor) {
			case 'AtZero':
				return A3(_elm_lang$core$Basics$clamp, _p16, _p15, 0);
			case 'Lowest':
				return _p16;
			default:
				return _p15;
		}
	});
var _terezka$elm_plot$Internal_Axis$placeTick = F5(
	function (_p18, _p17, axisPosition, view, info) {
		var _p19 = _p18;
		var _p20 = _p17;
		return A2(
			_elm_lang$svg$Svg$g,
			{
				ctor: '::',
				_0: _elm_lang$svg$Svg_Attributes$transform(
					A2(
						_elm_lang$core$Basics_ops['++'],
						_terezka$elm_plot$Internal_Draw$toTranslate(
							_p19.toSvgCoords(
								{ctor: '_Tuple2', _0: info.value, _1: axisPosition})),
						A2(
							_elm_lang$core$Basics_ops['++'],
							' ',
							A2(_terezka$elm_plot$Internal_Axis$toRotate, _p20.anchor, _p20.orientation)))),
				_1: {
					ctor: '::',
					_0: _elm_lang$svg$Svg_Attributes$class('elm-plot__axis__tick'),
					_1: {ctor: '[]'}
				}
			},
			{
				ctor: '::',
				_0: view(info),
				_1: {ctor: '[]'}
			});
	});
var _terezka$elm_plot$Internal_Axis$placeLabel = F4(
	function (_p22, _p21, axisPosition, info) {
		var _p23 = _p22;
		var _p24 = _p21;
		return {
			ctor: '::',
			_0: _elm_lang$svg$Svg_Attributes$transform(
				_terezka$elm_plot$Internal_Draw$toTranslate(
					A2(
						_terezka$elm_plot$Internal_Draw$addDisplacement,
						A2(_terezka$elm_plot$Internal_Axis$getDisplacement, _p24.anchor, _p24.orientation),
						_p23.toSvgCoords(
							{ctor: '_Tuple2', _0: info.value, _1: axisPosition})))),
			_1: {
				ctor: '::',
				_0: _elm_lang$svg$Svg_Attributes$class('elm-plot__axis__label'),
				_1: {ctor: '[]'}
			}
		};
	});
var _terezka$elm_plot$Internal_Axis$viewAxisLine = function (_p25) {
	var _p26 = _p25;
	return _terezka$elm_plot$Internal_Draw$fullLine(
		A2(
			_elm_lang$core$Basics_ops['++'],
			{
				ctor: '::',
				_0: _elm_lang$svg$Svg_Attributes$style(
					_terezka$elm_plot$Internal_Draw$toStyle(_p26.style)),
				_1: {
					ctor: '::',
					_0: _elm_lang$svg$Svg_Attributes$class('elm-plot__axis__line'),
					_1: {ctor: '[]'}
				}
			},
			_p26.customAttrs));
};
var _terezka$elm_plot$Internal_Axis$view = F2(
	function (_p28, _p27) {
		var _p29 = _p28;
		var _p33 = _p29;
		var _p30 = _p27;
		var _p32 = _p30.orientation;
		var _p31 = _p30;
		var axisPosition = A2(_terezka$elm_plot$Internal_Axis$getAxisPosition, _p29.scale.y, _p30.position);
		var tickValues = A2(_terezka$elm_plot$Internal_Axis$toTickValues, _p33, _p31);
		var labelValues = A2(_terezka$elm_plot$Internal_Axis$toLabelValues, _p31, tickValues);
		return A2(
			_elm_lang$svg$Svg$g,
			{
				ctor: '::',
				_0: A3(_terezka$elm_plot$Internal_Draw$classAttributeOriented, 'axis', _p32, _p30.classes),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A3(_terezka$elm_plot$Internal_Axis$viewAxisLine, _p30.lineConfig, _p33, axisPosition),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$svg$Svg$g,
						{
							ctor: '::',
							_0: _elm_lang$svg$Svg_Attributes$class('elm-plot__axis__ticks'),
							_1: {ctor: '[]'}
						},
						A2(
							_elm_lang$core$List$map,
							A4(
								_terezka$elm_plot$Internal_Axis$placeTick,
								_p33,
								_p31,
								axisPosition,
								A2(_terezka$elm_plot$Internal_Tick$toView, _p30.tickConfig, _p32)),
							_terezka$elm_plot$Internal_Axis$toIndexInfo(tickValues))),
					_1: {
						ctor: '::',
						_0: A2(
							_elm_lang$svg$Svg$g,
							{
								ctor: '::',
								_0: _elm_lang$svg$Svg_Attributes$class('elm-plot__axis__labels'),
								_1: {
									ctor: '::',
									_0: _elm_lang$svg$Svg_Attributes$style(
										A2(_terezka$elm_plot$Internal_Axis$toAnchorStyle, _p30.anchor, _p32)),
									_1: {ctor: '[]'}
								}
							},
							A3(
								_terezka$elm_plot$Internal_Label$view,
								_p30.labelConfig,
								A3(_terezka$elm_plot$Internal_Axis$placeLabel, _p33, _p31, axisPosition),
								_terezka$elm_plot$Internal_Axis$toIndexInfo(labelValues))),
						_1: {ctor: '[]'}
					}
				}
			});
	});
var _terezka$elm_plot$Internal_Axis$Config = function (a) {
	return function (b) {
		return function (c) {
			return function (d) {
				return function (e) {
					return function (f) {
						return function (g) {
							return function (h) {
								return function (i) {
									return function (j) {
										return {tickConfig: a, tickValues: b, labelConfig: c, labelValues: d, lineConfig: e, orientation: f, anchor: g, cleanCrossings: h, position: i, classes: j};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var _terezka$elm_plot$Internal_Axis$LabelInfo = F2(
	function (a, b) {
		return {value: a, index: b};
	});
var _terezka$elm_plot$Internal_Axis$AtZero = {ctor: 'AtZero'};
var _terezka$elm_plot$Internal_Axis$Highest = {ctor: 'Highest'};
var _terezka$elm_plot$Internal_Axis$Lowest = {ctor: 'Lowest'};
var _terezka$elm_plot$Internal_Axis$FromCustom = function (a) {
	return {ctor: 'FromCustom', _0: a};
};
var _terezka$elm_plot$Internal_Axis$FromCount = function (a) {
	return {ctor: 'FromCount', _0: a};
};
var _terezka$elm_plot$Internal_Axis$FromDelta = function (a) {
	return {ctor: 'FromDelta', _0: a};
};
var _terezka$elm_plot$Internal_Axis$AutoValues = {ctor: 'AutoValues'};
var _terezka$elm_plot$Internal_Axis$defaultConfigX = {
	tickConfig: _terezka$elm_plot$Internal_Tick$defaultConfig,
	tickValues: _terezka$elm_plot$Internal_Axis$AutoValues,
	labelConfig: _terezka$elm_plot$Internal_Label$toDefaultConfig(
		function (_p34) {
			return _elm_lang$core$Basics$toString(
				function (_) {
					return _.value;
				}(_p34));
		}),
	labelValues: _elm_lang$core$Maybe$Nothing,
	lineConfig: _terezka$elm_plot$Internal_Line$defaultConfig,
	orientation: _terezka$elm_plot$Internal_Types$X,
	cleanCrossings: false,
	anchor: _terezka$elm_plot$Internal_Types$Outer,
	position: _terezka$elm_plot$Internal_Axis$AtZero,
	classes: {ctor: '[]'}
};
var _terezka$elm_plot$Internal_Axis$defaultConfigY = _elm_lang$core$Native_Utils.update(
	_terezka$elm_plot$Internal_Axis$defaultConfigX,
	{orientation: _terezka$elm_plot$Internal_Types$Y});

var _terezka$elm_plot$Plot_Line$customAttrs = F2(
	function (attrs, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{customAttrs: attrs});
	});
var _terezka$elm_plot$Plot_Line$smoothingBezier = function (config) {
	return _elm_lang$core$Native_Utils.update(
		config,
		{smoothing: _terezka$elm_plot$Internal_Types$Bezier});
};
var _terezka$elm_plot$Plot_Line$opacity = F2(
	function (opacity, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				style: {
					ctor: '::',
					_0: {
						ctor: '_Tuple2',
						_0: 'opacity',
						_1: _elm_lang$core$Basics$toString(opacity)
					},
					_1: config.style
				}
			});
	});
var _terezka$elm_plot$Plot_Line$strokeWidth = F2(
	function (strokeWidth, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				style: {
					ctor: '::',
					_0: {
						ctor: '_Tuple2',
						_0: 'stroke-width',
						_1: _terezka$elm_plot$Internal_Draw$toPixelsInt(strokeWidth)
					},
					_1: config.style
				}
			});
	});
var _terezka$elm_plot$Plot_Line$stroke = F2(
	function (stroke, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				style: {
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: 'stroke', _1: stroke},
					_1: config.style
				}
			});
	});

var _terezka$elm_plot$Plot_Tick$viewCustom = F2(
	function (view, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				viewConfig: _terezka$elm_plot$Internal_Tick$FromCustomView(
					_elm_lang$core$Basics$always(view))
			});
	});
var _terezka$elm_plot$Plot_Tick$toStyleConfig = function (attributes) {
	return A3(
		_elm_lang$core$List$foldl,
		F2(
			function (x, y) {
				return x(y);
			}),
		_terezka$elm_plot$Internal_Tick$defaultStyleConfig,
		attributes);
};
var _terezka$elm_plot$Plot_Tick$view = F2(
	function (styles, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				viewConfig: _terezka$elm_plot$Internal_Tick$FromStyle(
					_terezka$elm_plot$Plot_Tick$toStyleConfig(styles))
			});
	});
var _terezka$elm_plot$Plot_Tick$viewDynamic = F2(
	function (toStyles, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				viewConfig: _terezka$elm_plot$Internal_Tick$FromStyleDynamic(
					function (_p0) {
						return _terezka$elm_plot$Plot_Tick$toStyleConfig(
							toStyles(_p0));
					})
			});
	});
var _terezka$elm_plot$Plot_Tick$customAttrs = F2(
	function (attrs, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{customAttrs: attrs});
	});
var _terezka$elm_plot$Plot_Tick$opacity = F2(
	function (opacity, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				style: {
					ctor: '::',
					_0: {
						ctor: '_Tuple2',
						_0: 'opacity',
						_1: _elm_lang$core$Basics$toString(opacity)
					},
					_1: config.style
				}
			});
	});
var _terezka$elm_plot$Plot_Tick$strokeWidth = F2(
	function (strokeWidth, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				style: {
					ctor: '::',
					_0: {
						ctor: '_Tuple2',
						_0: 'stroke-width',
						_1: _terezka$elm_plot$Internal_Draw$toPixelsInt(strokeWidth)
					},
					_1: config.style
				}
			});
	});
var _terezka$elm_plot$Plot_Tick$stroke = F2(
	function (stroke, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				style: {
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: 'stroke', _1: stroke},
					_1: config.style
				}
			});
	});
var _terezka$elm_plot$Plot_Tick$classes = F2(
	function (classes, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{classes: classes});
	});
var _terezka$elm_plot$Plot_Tick$width = F2(
	function (width, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{width: width});
	});
var _terezka$elm_plot$Plot_Tick$length = F2(
	function (length, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{length: length});
	});

var _terezka$elm_plot$Plot_Label$formatFromList = F2(
	function (format, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				format: _terezka$elm_plot$Internal_Label$FromList(format)
			});
	});
var _terezka$elm_plot$Plot_Label$format = F2(
	function (format, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				format: _terezka$elm_plot$Internal_Label$FromFunc(format)
			});
	});
var _terezka$elm_plot$Plot_Label$viewCustom = F2(
	function (view, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				viewConfig: _terezka$elm_plot$Internal_Label$FromCustomView(view)
			});
	});
var _terezka$elm_plot$Plot_Label$toStyleConfig = function (styleAttributes) {
	return A3(
		_elm_lang$core$List$foldl,
		F2(
			function (x, y) {
				return x(y);
			}),
		_terezka$elm_plot$Internal_Label$defaultStyleConfig,
		styleAttributes);
};
var _terezka$elm_plot$Plot_Label$view = F2(
	function (styles, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				viewConfig: _terezka$elm_plot$Internal_Label$FromStyle(
					_terezka$elm_plot$Plot_Label$toStyleConfig(styles))
			});
	});
var _terezka$elm_plot$Plot_Label$viewDynamic = F2(
	function (toStyles, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				viewConfig: _terezka$elm_plot$Internal_Label$FromStyleDynamic(
					function (_p0) {
						return _terezka$elm_plot$Plot_Label$toStyleConfig(
							toStyles(_p0));
					})
			});
	});
var _terezka$elm_plot$Plot_Label$customAttrs = F2(
	function (attrs, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{customAttrs: attrs});
	});
var _terezka$elm_plot$Plot_Label$fontSize = F2(
	function (fontSize, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				style: {
					ctor: '::',
					_0: {
						ctor: '_Tuple2',
						_0: 'font-size',
						_1: _terezka$elm_plot$Internal_Draw$toPixelsInt(fontSize)
					},
					_1: config.style
				}
			});
	});
var _terezka$elm_plot$Plot_Label$opacity = F2(
	function (opacity, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				style: {
					ctor: '::',
					_0: {
						ctor: '_Tuple2',
						_0: 'opacity',
						_1: _elm_lang$core$Basics$toString(opacity)
					},
					_1: config.style
				}
			});
	});
var _terezka$elm_plot$Plot_Label$fill = F2(
	function (fill, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				style: {
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: 'fill', _1: fill},
					_1: config.style
				}
			});
	});
var _terezka$elm_plot$Plot_Label$strokeWidth = F2(
	function (strokeWidth, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				style: {
					ctor: '::',
					_0: {
						ctor: '_Tuple2',
						_0: 'stroke-width',
						_1: _terezka$elm_plot$Internal_Draw$toPixelsInt(strokeWidth)
					},
					_1: config.style
				}
			});
	});
var _terezka$elm_plot$Plot_Label$stroke = F2(
	function (stroke, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				style: {
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: 'stroke', _1: stroke},
					_1: config.style
				}
			});
	});
var _terezka$elm_plot$Plot_Label$classes = F2(
	function (classes, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{classes: classes});
	});
var _terezka$elm_plot$Plot_Label$displace = F2(
	function (displace, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				displace: _elm_lang$core$Maybe$Just(displace)
			});
	});

var _terezka$elm_plot$Plot_Axis$tickDelta = F2(
	function (delta, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				tickValues: _terezka$elm_plot$Internal_Axis$FromDelta(delta)
			});
	});
var _terezka$elm_plot$Plot_Axis$tickValues = F2(
	function (values, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				tickValues: _terezka$elm_plot$Internal_Axis$FromCustom(values)
			});
	});
var _terezka$elm_plot$Plot_Axis$labelValues = F2(
	function (values, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				labelValues: _elm_lang$core$Maybe$Just(values)
			});
	});
var _terezka$elm_plot$Plot_Axis$label = F2(
	function (attributes, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				labelConfig: A3(
					_elm_lang$core$List$foldl,
					F2(
						function (x, y) {
							return x(y);
						}),
					_terezka$elm_plot$Internal_Label$defaultConfig,
					attributes)
			});
	});
var _terezka$elm_plot$Plot_Axis$tick = F2(
	function (attributes, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				tickConfig: A3(
					_elm_lang$core$List$foldl,
					F2(
						function (x, y) {
							return x(y);
						}),
					_terezka$elm_plot$Internal_Tick$defaultConfig,
					attributes)
			});
	});
var _terezka$elm_plot$Plot_Axis$cleanCrossings = function (config) {
	return _elm_lang$core$Native_Utils.update(
		config,
		{cleanCrossings: true});
};
var _terezka$elm_plot$Plot_Axis$positionHighest = function (config) {
	return _elm_lang$core$Native_Utils.update(
		config,
		{position: _terezka$elm_plot$Internal_Axis$Highest});
};
var _terezka$elm_plot$Plot_Axis$positionLowest = function (config) {
	return _elm_lang$core$Native_Utils.update(
		config,
		{position: _terezka$elm_plot$Internal_Axis$Lowest});
};
var _terezka$elm_plot$Plot_Axis$anchorInside = function (config) {
	return _elm_lang$core$Native_Utils.update(
		config,
		{anchor: _terezka$elm_plot$Internal_Types$Inner});
};
var _terezka$elm_plot$Plot_Axis$line = F2(
	function (attrs, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				lineConfig: A3(
					_elm_lang$core$List$foldr,
					F2(
						function (x, y) {
							return x(y);
						}),
					_terezka$elm_plot$Internal_Line$defaultConfig,
					attrs)
			});
	});
var _terezka$elm_plot$Plot_Axis$classes = F2(
	function (classes, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{classes: classes});
	});
var _terezka$elm_plot$Plot_Axis$LabelInfo = F2(
	function (a, b) {
		return {value: a, index: b};
	});

var _terezka$elm_plot$Internal_Grid$viewLine = function (_p0) {
	var _p1 = _p0;
	return _terezka$elm_plot$Internal_Draw$fullLine(
		A2(
			_elm_lang$core$Basics_ops['++'],
			{
				ctor: '::',
				_0: _elm_lang$svg$Svg_Attributes$style(
					_terezka$elm_plot$Internal_Draw$toStyle(_p1.style)),
				_1: {
					ctor: '::',
					_0: _elm_lang$svg$Svg_Attributes$class('elm-plot__grid__line'),
					_1: {ctor: '[]'}
				}
			},
			_p1.customAttrs));
};
var _terezka$elm_plot$Internal_Grid$getValues = F2(
	function (tickValues, values) {
		var _p2 = values;
		if (_p2.ctor === 'MirrorTicks') {
			return tickValues;
		} else {
			return _p2._0;
		}
	});
var _terezka$elm_plot$Internal_Grid$viewLines = F2(
	function (_p4, _p3) {
		var _p5 = _p4;
		var _p6 = _p3;
		return A2(
			_elm_lang$core$List$map,
			A2(_terezka$elm_plot$Internal_Grid$viewLine, _p6.linesConfig, _p5),
			A2(_terezka$elm_plot$Internal_Grid$getValues, _p5.oppositeTicks, _p6.values));
	});
var _terezka$elm_plot$Internal_Grid$view = F2(
	function (meta, _p7) {
		var _p8 = _p7;
		return A2(
			_elm_lang$svg$Svg$g,
			{
				ctor: '::',
				_0: A3(_terezka$elm_plot$Internal_Draw$classAttributeOriented, 'grid', _p8.orientation, _p8.classes),
				_1: {ctor: '[]'}
			},
			A2(_terezka$elm_plot$Internal_Grid$viewLines, meta, _p8));
	});
var _terezka$elm_plot$Internal_Grid$Config = F5(
	function (a, b, c, d, e) {
		return {values: a, linesConfig: b, classes: c, orientation: d, customAttrs: e};
	});
var _terezka$elm_plot$Internal_Grid$CustomValues = function (a) {
	return {ctor: 'CustomValues', _0: a};
};
var _terezka$elm_plot$Internal_Grid$MirrorTicks = {ctor: 'MirrorTicks'};
var _terezka$elm_plot$Internal_Grid$defaultConfigX = {
	values: _terezka$elm_plot$Internal_Grid$MirrorTicks,
	linesConfig: _terezka$elm_plot$Internal_Line$defaultConfig,
	classes: {ctor: '[]'},
	orientation: _terezka$elm_plot$Internal_Types$X,
	customAttrs: {ctor: '[]'}
};
var _terezka$elm_plot$Internal_Grid$defaultConfigY = _elm_lang$core$Native_Utils.update(
	_terezka$elm_plot$Internal_Grid$defaultConfigX,
	{orientation: _terezka$elm_plot$Internal_Types$Y});

var _terezka$elm_plot$Plot_Grid$customAttrs = F2(
	function (attrs, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{customAttrs: attrs});
	});
var _terezka$elm_plot$Plot_Grid$classes = F2(
	function (classes, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{classes: classes});
	});
var _terezka$elm_plot$Plot_Grid$lines = F2(
	function (attrs, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				linesConfig: A3(
					_elm_lang$core$List$foldr,
					F2(
						function (x, y) {
							return x(y);
						}),
					_terezka$elm_plot$Internal_Line$defaultConfig,
					attrs)
			});
	});
var _terezka$elm_plot$Plot_Grid$values = F2(
	function (values, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				values: _terezka$elm_plot$Internal_Grid$CustomValues(values)
			});
	});

var _terezka$elm_plot$Internal_Area$stdAttributes = F2(
	function (d, style) {
		return {
			ctor: '::',
			_0: _elm_lang$svg$Svg_Attributes$d(
				A2(_elm_lang$core$Basics_ops['++'], d, 'Z')),
			_1: {
				ctor: '::',
				_0: _elm_lang$svg$Svg_Attributes$style(
					_terezka$elm_plot$Internal_Draw$toStyle(style)),
				_1: {
					ctor: '::',
					_0: _elm_lang$svg$Svg_Attributes$class('elm-plot__serie--area'),
					_1: {ctor: '[]'}
				}
			}
		};
	});
var _terezka$elm_plot$Internal_Area$view = F3(
	function (_p1, _p0, points) {
		var _p2 = _p1;
		var _p8 = _p2.toSvgCoords;
		var _p7 = _p2.scale;
		var _p3 = _p0;
		var areaEnd = A3(_elm_lang$core$Basics$clamp, _p7.y.lowest, _p7.y.highest, 0);
		var svgCoords = A2(_elm_lang$core$List$map, _p8, points);
		var instructions = A2(_terezka$elm_plot$Internal_Draw$toLineInstructions, _p3.smoothing, svgCoords);
		var _p4 = _terezka$elm_plot$Internal_Stuff$getEdgesX(points);
		var lowestX = _p4._0;
		var highestX = _p4._1;
		var _p5 = _p8(
			{ctor: '_Tuple2', _0: highestX, _1: areaEnd});
		var highestSvgX = _p5._0;
		var originY = _p5._1;
		var endInstructions = A2(
			_terezka$elm_plot$Internal_Draw$toInstruction,
			'L',
			{
				ctor: '::',
				_0: highestSvgX,
				_1: {
					ctor: '::',
					_0: originY,
					_1: {ctor: '[]'}
				}
			});
		var _p6 = _p8(
			{ctor: '_Tuple2', _0: lowestX, _1: areaEnd});
		var lowestSvgX = _p6._0;
		var startInstruction = A2(
			_terezka$elm_plot$Internal_Draw$toInstruction,
			'M',
			{
				ctor: '::',
				_0: lowestSvgX,
				_1: {
					ctor: '::',
					_0: originY,
					_1: {ctor: '[]'}
				}
			});
		var attrs = A2(
			_elm_lang$core$Basics_ops['++'],
			A2(
				_terezka$elm_plot$Internal_Area$stdAttributes,
				A2(
					_elm_lang$core$Basics_ops['++'],
					startInstruction,
					A2(_elm_lang$core$Basics_ops['++'], instructions, endInstructions)),
				_p3.style),
			_p3.customAttrs);
		return A2(
			_elm_lang$svg$Svg$path,
			attrs,
			{ctor: '[]'});
	});
var _terezka$elm_plot$Internal_Area$defaultConfig = {
	style: {ctor: '[]'},
	smoothing: _terezka$elm_plot$Internal_Types$None,
	customAttrs: {ctor: '[]'}
};
var _terezka$elm_plot$Internal_Area$Config = F3(
	function (a, b, c) {
		return {style: a, smoothing: b, customAttrs: c};
	});

var _terezka$elm_plot$Plot_Area$customAttrs = F2(
	function (attrs, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{customAttrs: attrs});
	});
var _terezka$elm_plot$Plot_Area$smoothingBezier = function (config) {
	return _elm_lang$core$Native_Utils.update(
		config,
		{smoothing: _terezka$elm_plot$Internal_Types$Bezier});
};
var _terezka$elm_plot$Plot_Area$opacity = F2(
	function (opacity, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				style: {
					ctor: '::',
					_0: {
						ctor: '_Tuple2',
						_0: 'opacity',
						_1: _elm_lang$core$Basics$toString(opacity)
					},
					_1: config.style
				}
			});
	});
var _terezka$elm_plot$Plot_Area$fill = F2(
	function (fill, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				style: {
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: 'fill', _1: fill},
					_1: config.style
				}
			});
	});
var _terezka$elm_plot$Plot_Area$strokeWidth = F2(
	function (strokeWidth, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				style: {
					ctor: '::',
					_0: {
						ctor: '_Tuple2',
						_0: 'stroke-width',
						_1: _terezka$elm_plot$Internal_Draw$toPixelsInt(strokeWidth)
					},
					_1: config.style
				}
			});
	});
var _terezka$elm_plot$Plot_Area$stroke = F2(
	function (stroke, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				style: {
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: 'stroke', _1: stroke},
					_1: config.style
				}
			});
	});

var _terezka$elm_plot$Internal_Bars$getYValues = F2(
	function (xValue, groups) {
		return _elm_lang$core$Tuple$second(
			A2(
				_elm_lang$core$Maybe$withDefault,
				{ctor: '_Tuple2', _0: 0, _1: _elm_lang$core$Maybe$Nothing},
				_elm_lang$core$List$head(
					A2(
						_elm_lang$core$List$filter,
						function (_p0) {
							var _p1 = _p0;
							return _elm_lang$core$Native_Utils.eq(_p1._0, xValue);
						},
						A2(
							_elm_lang$core$List$map,
							function (_p2) {
								var _p3 = _p2;
								return {
									ctor: '_Tuple2',
									_0: _p3.xValue,
									_1: _elm_lang$core$Maybe$Just(_p3.yValues)
								};
							},
							groups)))));
	});
var _terezka$elm_plot$Internal_Bars$foldPoints = F3(
	function (_p5, _p4, points) {
		var _p6 = _p5;
		var _p7 = _p4;
		var _p10 = _p7.yValues;
		var _p9 = _p7.xValue;
		if (_elm_lang$core$Native_Utils.eq(_p6.stackBy, _terezka$elm_plot$Internal_Types$X)) {
			return A2(
				_elm_lang$core$Basics_ops['++'],
				points,
				{
					ctor: '::',
					_0: {
						ctor: '_Tuple2',
						_0: _p9,
						_1: _terezka$elm_plot$Internal_Stuff$getLowest(_p10)
					},
					_1: {
						ctor: '::',
						_0: {
							ctor: '_Tuple2',
							_0: _p9,
							_1: _terezka$elm_plot$Internal_Stuff$getHighest(_p10)
						},
						_1: {ctor: '[]'}
					}
				});
		} else {
			var _p8 = A2(
				_elm_lang$core$List$partition,
				function (y) {
					return _elm_lang$core$Native_Utils.cmp(y, 0) > -1;
				},
				_p10);
			var positive = _p8._0;
			var negative = _p8._1;
			return A2(
				_elm_lang$core$Basics_ops['++'],
				points,
				{
					ctor: '::',
					_0: {
						ctor: '_Tuple2',
						_0: _p9,
						_1: _elm_lang$core$List$sum(positive)
					},
					_1: {
						ctor: '::',
						_0: {
							ctor: '_Tuple2',
							_0: _p9,
							_1: _elm_lang$core$List$sum(negative)
						},
						_1: {ctor: '[]'}
					}
				});
		}
	});
var _terezka$elm_plot$Internal_Bars$toPoints = F2(
	function (config, groups) {
		return A3(
			_elm_lang$core$List$foldl,
			_terezka$elm_plot$Internal_Bars$foldPoints(config),
			{ctor: '[]'},
			groups);
	});
var _terezka$elm_plot$Internal_Bars$toBarWidth = F3(
	function (_p11, groups, $default) {
		var _p12 = _p11;
		var _p13 = _p12.maxWidth;
		if (_p13.ctor === 'Percentage') {
			return ($default * _elm_lang$core$Basics$toFloat(_p13._0)) / 100;
		} else {
			var _p14 = _p13._0;
			return (_elm_lang$core$Native_Utils.cmp(
				$default,
				_elm_lang$core$Basics$toFloat(_p14)) > 0) ? _elm_lang$core$Basics$toFloat(_p14) : $default;
		}
	});
var _terezka$elm_plot$Internal_Bars$toAutoWidth = F4(
	function (_p16, _p15, styleConfigs, groups) {
		var _p17 = _p16;
		var _p20 = _p17.scale;
		var _p18 = _p15;
		var width = function () {
			var _p19 = _p18.stackBy;
			if (_p19.ctor === 'X') {
				return 1 / _elm_lang$core$Basics$toFloat(
					_elm_lang$core$List$length(styleConfigs));
			} else {
				return 1;
			}
		}();
		return (width * _p20.x.length) / _p20.x.range;
	});
var _terezka$elm_plot$Internal_Bars$placeLabel = F2(
	function (width, _p21) {
		var _p22 = _p21;
		return {
			ctor: '::',
			_0: _elm_lang$svg$Svg_Attributes$transform(
				_terezka$elm_plot$Internal_Draw$toTranslate(
					{ctor: '_Tuple2', _0: _p22._0 + (width / 2), _1: _p22._1})),
			_1: {
				ctor: '::',
				_0: _elm_lang$svg$Svg_Attributes$style('text-anchor: middle;'),
				_1: {ctor: '[]'}
			}
		};
	});
var _terezka$elm_plot$Internal_Bars$toYStackedOffset = F2(
	function (_p24, _p23) {
		var _p25 = _p24;
		var _p26 = _p23;
		return _elm_lang$core$List$sum(
			A2(
				_elm_lang$core$List$filter,
				function (y) {
					return _elm_lang$core$Native_Utils.eq(
						_elm_lang$core$Native_Utils.cmp(y, 0) < 0,
						_elm_lang$core$Native_Utils.cmp(_p26.yValue, 0) < 0);
				},
				A2(_elm_lang$core$List$take, _p26.index, _p25.yValues)));
	});
var _terezka$elm_plot$Internal_Bars$toXStackedOffset = F3(
	function (styleConfigs, width, _p27) {
		var _p28 = _p27;
		var offsetBar = _elm_lang$core$Basics$toFloat(_p28.index) * width;
		var offsetGroup = (_elm_lang$core$Basics$toFloat(
			_elm_lang$core$List$length(styleConfigs)) * width) / 2;
		return offsetBar - offsetGroup;
	});
var _terezka$elm_plot$Internal_Bars$toLengthTouchingXAxis = F3(
	function (_p30, config, _p29) {
		var _p31 = _p30;
		var _p33 = _p31.scale;
		var _p32 = _p29;
		return ((_p32.yValue - A3(_elm_lang$core$Basics$clamp, _p33.y.lowest, _p33.y.highest, 0)) * _p33.y.length) / _p33.y.range;
	});
var _terezka$elm_plot$Internal_Bars$toLength = F3(
	function (meta, config, bar) {
		var _p34 = config.stackBy;
		if (_p34.ctor === 'X') {
			return A3(_terezka$elm_plot$Internal_Bars$toLengthTouchingXAxis, meta, config, bar);
		} else {
			return _elm_lang$core$Native_Utils.eq(bar.index, 0) ? A3(_terezka$elm_plot$Internal_Bars$toLengthTouchingXAxis, meta, config, bar) : ((bar.yValue * meta.scale.y.length) / meta.scale.y.range);
		}
	});
var _terezka$elm_plot$Internal_Bars$toStackedCoords = F6(
	function (meta, config, styleConfigs, width, group, bar) {
		var _p35 = config.stackBy;
		if (_p35.ctor === 'X') {
			return A2(
				_terezka$elm_plot$Internal_Draw$addDisplacement,
				{
					ctor: '_Tuple2',
					_0: A3(_terezka$elm_plot$Internal_Bars$toXStackedOffset, styleConfigs, width, bar),
					_1: 0
				},
				meta.toSvgCoords(
					{
						ctor: '_Tuple2',
						_0: bar.xValue,
						_1: A2(
							_elm_lang$core$Basics$max,
							A2(_elm_lang$core$Basics$min, 0, meta.scale.y.highest),
							bar.yValue)
					}));
		} else {
			return A2(
				_terezka$elm_plot$Internal_Draw$addDisplacement,
				{
					ctor: '_Tuple2',
					_0: (0 - width) / 2,
					_1: A2(
						_elm_lang$core$Basics$min,
						0,
						A3(_terezka$elm_plot$Internal_Bars$toLength, meta, config, bar))
				},
				meta.toSvgCoords(
					A2(
						_terezka$elm_plot$Internal_Draw$addDisplacement,
						{
							ctor: '_Tuple2',
							_0: 0,
							_1: A2(_terezka$elm_plot$Internal_Bars$toYStackedOffset, group, bar)
						},
						{ctor: '_Tuple2', _0: bar.xValue, _1: bar.yValue})));
		}
	});
var _terezka$elm_plot$Internal_Bars$viewBar = F6(
	function (meta, width, _p36, config, styleConfig, info) {
		var _p37 = _p36;
		return A2(
			_elm_lang$svg$Svg$rect,
			A2(
				_elm_lang$core$Basics_ops['++'],
				{
					ctor: '::',
					_0: _elm_lang$svg$Svg_Attributes$x(
						_elm_lang$core$Basics$toString(_p37._0)),
					_1: {
						ctor: '::',
						_0: _elm_lang$svg$Svg_Attributes$y(
							_elm_lang$core$Basics$toString(_p37._1)),
						_1: {
							ctor: '::',
							_0: _elm_lang$svg$Svg_Attributes$width(
								_elm_lang$core$Basics$toString(width)),
							_1: {
								ctor: '::',
								_0: _elm_lang$svg$Svg_Attributes$height(
									_elm_lang$core$Basics$toString(
										_elm_lang$core$Basics$abs(
											A3(_terezka$elm_plot$Internal_Bars$toLength, meta, config, info)))),
								_1: {
									ctor: '::',
									_0: _elm_lang$svg$Svg_Attributes$style(
										_terezka$elm_plot$Internal_Draw$toStyle(styleConfig.style)),
									_1: {ctor: '[]'}
								}
							}
						}
					}
				},
				styleConfig.customAttrs),
			{ctor: '[]'});
	});
var _terezka$elm_plot$Internal_Bars$viewGroup = F5(
	function (meta, config, styleConfigs, width, group) {
		var toCoords = A5(_terezka$elm_plot$Internal_Bars$toStackedCoords, meta, config, styleConfigs, width, group);
		var labelInfos = A2(
			_elm_lang$core$List$indexedMap,
			F2(
				function (i, y) {
					return {index: i, xValue: group.xValue, yValue: y};
				}),
			group.yValues);
		return A2(
			_elm_lang$svg$Svg$g,
			{ctor: '[]'},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$svg$Svg$g,
					{ctor: '[]'},
					A3(
						_elm_lang$core$List$map2,
						F2(
							function (styleConfig, info) {
								return A6(
									_terezka$elm_plot$Internal_Bars$viewBar,
									meta,
									width,
									toCoords(info),
									config,
									styleConfig,
									info);
							}),
						styleConfigs,
						labelInfos)),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$svg$Svg$g,
						{ctor: '[]'},
						A3(
							_terezka$elm_plot$Internal_Label$view,
							config.labelConfig,
							function (info) {
								return A2(
									_terezka$elm_plot$Internal_Bars$placeLabel,
									width,
									toCoords(info));
							},
							labelInfos)),
					_1: {ctor: '[]'}
				}
			});
	});
var _terezka$elm_plot$Internal_Bars$view = F4(
	function (meta, config, styleConfigs, groups) {
		var width = A3(
			_terezka$elm_plot$Internal_Bars$toBarWidth,
			config,
			groups,
			A4(_terezka$elm_plot$Internal_Bars$toAutoWidth, meta, config, styleConfigs, groups));
		return A2(
			_elm_lang$svg$Svg$g,
			{ctor: '[]'},
			A2(
				_elm_lang$core$List$map,
				A4(_terezka$elm_plot$Internal_Bars$viewGroup, meta, config, styleConfigs, width),
				groups));
	});
var _terezka$elm_plot$Internal_Bars$defaultStyleConfig = {
	style: {
		ctor: '::',
		_0: {ctor: '_Tuple2', _0: 'stroke', _1: 'transparent'},
		_1: {ctor: '[]'}
	},
	customAttrs: {ctor: '[]'}
};
var _terezka$elm_plot$Internal_Bars$defaultConfig = {
	stackBy: _terezka$elm_plot$Internal_Types$X,
	labelConfig: _terezka$elm_plot$Internal_Label$defaultConfig,
	maxWidth: _terezka$elm_plot$Internal_Types$Percentage(100)
};
var _terezka$elm_plot$Internal_Bars$Group = F2(
	function (a, b) {
		return {xValue: a, yValues: b};
	});
var _terezka$elm_plot$Internal_Bars$Config = F3(
	function (a, b, c) {
		return {stackBy: a, labelConfig: b, maxWidth: c};
	});
var _terezka$elm_plot$Internal_Bars$StyleConfig = F2(
	function (a, b) {
		return {style: a, customAttrs: b};
	});
var _terezka$elm_plot$Internal_Bars$LabelInfo = F3(
	function (a, b, c) {
		return {index: a, xValue: b, yValue: c};
	});

var _terezka$elm_plot$Plot_Bars$getXValue = F3(
	function (_p0, index, data) {
		var _p1 = _p0;
		var _p2 = _p1.xValue;
		if (_p2.ctor === 'Just') {
			return _p2._0(data);
		} else {
			return _elm_lang$core$Basics$toFloat(index) + 1;
		}
	});
var _terezka$elm_plot$Plot_Bars$toBarData = F2(
	function (transform, allData) {
		return A2(
			_elm_lang$core$List$indexedMap,
			F2(
				function (index, data) {
					return {
						xValue: A3(_terezka$elm_plot$Plot_Bars$getXValue, transform, index, data),
						yValues: transform.yValues(data)
					};
				}),
			allData);
	});
var _terezka$elm_plot$Plot_Bars$customAttrs = F2(
	function (attrs, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{customAttrs: attrs});
	});
var _terezka$elm_plot$Plot_Bars$opacity = F2(
	function (opacity, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				style: {
					ctor: '::',
					_0: {
						ctor: '_Tuple2',
						_0: 'opacity',
						_1: _elm_lang$core$Basics$toString(opacity)
					},
					_1: config.style
				}
			});
	});
var _terezka$elm_plot$Plot_Bars$fill = F2(
	function (fill, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				style: {
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: 'fill', _1: fill},
					_1: config.style
				}
			});
	});
var _terezka$elm_plot$Plot_Bars$stackByY = function (config) {
	return _elm_lang$core$Native_Utils.update(
		config,
		{stackBy: _terezka$elm_plot$Internal_Types$Y});
};
var _terezka$elm_plot$Plot_Bars$label = F2(
	function (attributes, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				labelConfig: A3(
					_elm_lang$core$List$foldl,
					F2(
						function (x, y) {
							return x(y);
						}),
					_terezka$elm_plot$Internal_Label$defaultConfig,
					attributes)
			});
	});
var _terezka$elm_plot$Plot_Bars$maxBarWidthPer = F2(
	function (max, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				maxWidth: _terezka$elm_plot$Internal_Types$Percentage(max)
			});
	});
var _terezka$elm_plot$Plot_Bars$maxBarWidth = F2(
	function (max, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				maxWidth: _terezka$elm_plot$Internal_Types$Fixed(max)
			});
	});
var _terezka$elm_plot$Plot_Bars$LabelInfo = F3(
	function (a, b, c) {
		return {index: a, xValue: b, yValue: c};
	});
var _terezka$elm_plot$Plot_Bars$DataTransformers = F2(
	function (a, b) {
		return {yValues: a, xValue: b};
	});

var _terezka$elm_plot$Internal_Scatter$toSvgCircle = F2(
	function (radius, _p0) {
		var _p1 = _p0;
		return A2(
			_elm_lang$svg$Svg$circle,
			{
				ctor: '::',
				_0: _elm_lang$svg$Svg_Attributes$cx(
					_elm_lang$core$Basics$toString(_p1._0)),
				_1: {
					ctor: '::',
					_0: _elm_lang$svg$Svg_Attributes$cy(
						_elm_lang$core$Basics$toString(_p1._1)),
					_1: {
						ctor: '::',
						_0: _elm_lang$svg$Svg_Attributes$r(
							_elm_lang$core$Basics$toString(radius)),
						_1: {ctor: '[]'}
					}
				}
			},
			{ctor: '[]'});
	});
var _terezka$elm_plot$Internal_Scatter$view = F3(
	function (_p3, _p2, points) {
		var _p4 = _p3;
		var _p5 = _p2;
		var svgPoints = A2(_elm_lang$core$List$map, _p4.toSvgCoords, points);
		return A2(
			_elm_lang$svg$Svg$g,
			{
				ctor: '::',
				_0: _elm_lang$svg$Svg_Attributes$style(
					_terezka$elm_plot$Internal_Draw$toStyle(_p5.style)),
				_1: {ctor: '[]'}
			},
			A2(
				_elm_lang$core$List$map,
				_terezka$elm_plot$Internal_Scatter$toSvgCircle(_p5.radius),
				svgPoints));
	});
var _terezka$elm_plot$Internal_Scatter$defaultConfig = {
	style: {
		ctor: '::',
		_0: {ctor: '_Tuple2', _0: 'fill', _1: 'transparent'},
		_1: {ctor: '[]'}
	},
	customAttrs: {ctor: '[]'},
	radius: 5
};
var _terezka$elm_plot$Internal_Scatter$Config = F3(
	function (a, b, c) {
		return {style: a, customAttrs: b, radius: c};
	});

var _terezka$elm_plot$Plot_Scatter$customAttrs = F2(
	function (attrs, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{customAttrs: attrs});
	});
var _terezka$elm_plot$Plot_Scatter$radius = F2(
	function (radius, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{radius: radius});
	});
var _terezka$elm_plot$Plot_Scatter$opacity = F2(
	function (opacity, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				style: {
					ctor: '::',
					_0: {
						ctor: '_Tuple2',
						_0: 'opacity',
						_1: _elm_lang$core$Basics$toString(opacity)
					},
					_1: config.style
				}
			});
	});
var _terezka$elm_plot$Plot_Scatter$fill = F2(
	function (fill, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				style: {
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: 'fill', _1: fill},
					_1: config.style
				}
			});
	});
var _terezka$elm_plot$Plot_Scatter$strokeWidth = F2(
	function (strokeWidth, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				style: {
					ctor: '::',
					_0: {
						ctor: '_Tuple2',
						_0: 'stroke-width',
						_1: A2(
							_elm_lang$core$Basics_ops['++'],
							_elm_lang$core$Basics$toString(strokeWidth),
							'px')
					},
					_1: config.style
				}
			});
	});
var _terezka$elm_plot$Plot_Scatter$stroke = F2(
	function (stroke, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				style: {
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: 'stroke', _1: stroke},
					_1: config.style
				}
			});
	});

var _terezka$elm_plot$Internal_Hint$viewYValue = F2(
	function (index, hintValue) {
		var hintValueDisplayed = function () {
			var _p0 = hintValue;
			if (_p0.ctor === 'Just') {
				var _p2 = _p0._0;
				var _p1 = _p2;
				if ((_p1.ctor === '::') && (_p1._1.ctor === '[]')) {
					return _elm_lang$core$Basics$toString(_p1._0);
				} else {
					return _elm_lang$core$Basics$toString(_p2);
				}
			} else {
				return '~';
			}
		}();
		return A2(
			_elm_lang$html$Html$div,
			{ctor: '[]'},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$span,
					{ctor: '[]'},
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text(
							A2(
								_elm_lang$core$Basics_ops['++'],
								'Serie ',
								A2(
									_elm_lang$core$Basics_ops['++'],
									_elm_lang$core$Basics$toString(index),
									': '))),
						_1: {ctor: '[]'}
					}),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$span,
						{ctor: '[]'},
						{
							ctor: '::',
							_0: _elm_lang$html$Html$text(hintValueDisplayed),
							_1: {ctor: '[]'}
						}),
					_1: {ctor: '[]'}
				}
			});
	});
var _terezka$elm_plot$Internal_Hint$defaultView = F2(
	function (_p3, isLeftSide) {
		var _p4 = _p3;
		var classes = {
			ctor: '::',
			_0: {ctor: '_Tuple2', _0: 'elm-plot__hint__default-view', _1: true},
			_1: {
				ctor: '::',
				_0: {ctor: '_Tuple2', _0: 'elm-plot__hint__default-view--left', _1: isLeftSide},
				_1: {
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: 'elm-plot__hint__default-view--right', _1: !isLeftSide},
					_1: {ctor: '[]'}
				}
			}
		};
		return A2(
			_elm_lang$html$Html$div,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$classList(classes),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$div,
					{ctor: '[]'},
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text(
							A2(
								_elm_lang$core$Basics_ops['++'],
								'X: ',
								_elm_lang$core$Basics$toString(_p4.xValue))),
						_1: {ctor: '[]'}
					}),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$div,
						{ctor: '[]'},
						A2(_elm_lang$core$List$indexedMap, _terezka$elm_plot$Internal_Hint$viewYValue, _p4.yValues)),
					_1: {ctor: '[]'}
				}
			});
	});
var _terezka$elm_plot$Internal_Hint$viewLine = F2(
	function (style, length) {
		return A2(
			_elm_lang$html$Html$div,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('elm-plot__hint__line'),
				_1: {
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$style(
						A2(
							_elm_lang$core$Basics_ops['++'],
							{
								ctor: '::',
								_0: {
									ctor: '_Tuple2',
									_0: 'height',
									_1: _terezka$elm_plot$Internal_Draw$toPixels(length)
								},
								_1: {ctor: '[]'}
							},
							style)),
					_1: {ctor: '[]'}
				}
			},
			{ctor: '[]'});
	});
var _terezka$elm_plot$Internal_Hint$view = F3(
	function (_p6, _p5, position) {
		var _p7 = _p6;
		var _p10 = _p7.scale;
		var _p8 = _p5;
		var lineView = {
			ctor: '::',
			_0: A2(_terezka$elm_plot$Internal_Hint$viewLine, _p8.lineStyle, _p10.y.length),
			_1: {ctor: '[]'}
		};
		var info = _p7.getHintInfo(
			_elm_lang$core$Tuple$first(position));
		var _p9 = _p7.toSvgCoords(
			{ctor: '_Tuple2', _0: info.xValue, _1: 0});
		var xSvg = _p9._0;
		var ySvg = _p9._1;
		var isLeftSide = _elm_lang$core$Native_Utils.cmp(xSvg - _p10.x.offset.lower, _p10.x.length / 2) < 0;
		return A2(
			_elm_lang$html$Html$div,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('elm-plot__hint'),
				_1: {
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$style(
						{
							ctor: '::',
							_0: {
								ctor: '_Tuple2',
								_0: 'left',
								_1: _terezka$elm_plot$Internal_Draw$toPixels(xSvg)
							},
							_1: {
								ctor: '::',
								_0: {
									ctor: '_Tuple2',
									_0: 'top',
									_1: _terezka$elm_plot$Internal_Draw$toPixels(_p10.y.offset.lower)
								},
								_1: {
									ctor: '::',
									_0: {ctor: '_Tuple2', _0: 'position', _1: 'absolute'},
									_1: {ctor: '[]'}
								}
							}
						}),
					_1: {ctor: '[]'}
				}
			},
			{
				ctor: '::',
				_0: A2(_p8.view, info, isLeftSide),
				_1: lineView
			});
	});
var _terezka$elm_plot$Internal_Hint$defaultConfig = {
	view: _terezka$elm_plot$Internal_Hint$defaultView,
	lineStyle: {ctor: '[]'}
};
var _terezka$elm_plot$Internal_Hint$Config = F2(
	function (a, b) {
		return {view: a, lineStyle: b};
	});

var _terezka$elm_plot$Plot_Hint$viewCustom = F2(
	function (view, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{view: view});
	});
var _terezka$elm_plot$Plot_Hint$lineStyle = F2(
	function (style, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{lineStyle: style});
	});
var _terezka$elm_plot$Plot_Hint$HintInfo = F2(
	function (a, b) {
		return {xValue: a, yValues: b};
	});

var _terezka$elm_plot$Internal_Scale$unScaleValue = F2(
	function (_p0, v) {
		var _p1 = _p0;
		return (((v - _p1.offset.lower) * _p1.range) / _p1.length) + _p1.lowest;
	});
var _terezka$elm_plot$Internal_Scale$fromSvgCoords = F3(
	function (xScale, yScale, _p2) {
		var _p3 = _p2;
		return {
			ctor: '_Tuple2',
			_0: A2(_terezka$elm_plot$Internal_Scale$unScaleValue, xScale, _p3._0),
			_1: A2(_terezka$elm_plot$Internal_Scale$unScaleValue, yScale, yScale.length - _p3._1)
		};
	});
var _terezka$elm_plot$Internal_Scale$scaleValue = F2(
	function (_p4, v) {
		var _p5 = _p4;
		return ((v * _p5.length) / _p5.range) + _p5.offset.lower;
	});
var _terezka$elm_plot$Internal_Scale$toSvgCoordsX = F3(
	function (xScale, yScale, _p6) {
		var _p7 = _p6;
		return {
			ctor: '_Tuple2',
			_0: A2(_terezka$elm_plot$Internal_Scale$scaleValue, xScale, _p7._0 - xScale.lowest),
			_1: A2(_terezka$elm_plot$Internal_Scale$scaleValue, yScale, yScale.highest - _p7._1)
		};
	});
var _terezka$elm_plot$Internal_Scale$toSvgCoordsY = F3(
	function (xScale, yScale, _p8) {
		var _p9 = _p8;
		return A3(
			_terezka$elm_plot$Internal_Scale$toSvgCoordsX,
			xScale,
			yScale,
			{ctor: '_Tuple2', _0: _p9._1, _1: _p9._0});
	});
var _terezka$elm_plot$Internal_Scale$getScale = F6(
	function (lengthTotal, restrictRange, internalBounds, offset, _p10, values) {
		var _p11 = _p10;
		var boundsNatural = A2(
			_terezka$elm_plot$Internal_Types$Edges,
			_terezka$elm_plot$Internal_Stuff$getLowest(values),
			_terezka$elm_plot$Internal_Stuff$getHighest(values));
		var boundsPadded = A2(_terezka$elm_plot$Internal_Stuff$foldBounds, internalBounds, boundsNatural);
		var bounds = {
			lower: restrictRange.lower(boundsPadded.lower),
			upper: restrictRange.upper(boundsPadded.upper)
		};
		var range = A2(_terezka$elm_plot$Internal_Stuff$getRange, bounds.lower, bounds.upper);
		var length = (lengthTotal - offset.lower) - offset.upper;
		var paddingTop = A3(_terezka$elm_plot$Internal_Stuff$pixelsToValue, length, range, _p11._1);
		var paddingBottom = A3(_terezka$elm_plot$Internal_Stuff$pixelsToValue, length, range, _p11._0);
		return {lowest: bounds.lower - paddingBottom, highest: bounds.upper + paddingTop, range: (range + paddingBottom) + paddingTop, length: length, offset: offset};
	});

var _terezka$elm_plot$Plot$getAxisCrossings = F2(
	function (axisConfigs, oppositeScale) {
		return A2(
			_elm_lang$core$List$map,
			function (_p0) {
				return A2(
					_terezka$elm_plot$Internal_Axis$getAxisPosition,
					oppositeScale,
					function (_) {
						return _.position;
					}(_p0));
			},
			axisConfigs);
	});
var _terezka$elm_plot$Plot$getYValue = F3(
	function (xValue, _p1, result) {
		var _p2 = _p1;
		return _elm_lang$core$Native_Utils.eq(_p2._0, xValue) ? _elm_lang$core$Maybe$Just(
			{
				ctor: '::',
				_0: _p2._1,
				_1: {ctor: '[]'}
			}) : result;
	});
var _terezka$elm_plot$Plot$collectYValue = F2(
	function (xValue, points) {
		return A3(
			_elm_lang$core$List$foldr,
			_terezka$elm_plot$Plot$getYValue(xValue),
			_elm_lang$core$Maybe$Nothing,
			points);
	});
var _terezka$elm_plot$Plot$collectYValues = F3(
	function (xValue, element, yValues) {
		var _p3 = element;
		switch (_p3.ctor) {
			case 'Area':
				return {
					ctor: '::',
					_0: A2(_terezka$elm_plot$Plot$collectYValue, xValue, _p3._1),
					_1: yValues
				};
			case 'Line':
				return {
					ctor: '::',
					_0: A2(_terezka$elm_plot$Plot$collectYValue, xValue, _p3._1),
					_1: yValues
				};
			case 'Scatter':
				return {
					ctor: '::',
					_0: A2(_terezka$elm_plot$Plot$collectYValue, xValue, _p3._1),
					_1: yValues
				};
			case 'Bars':
				return {
					ctor: '::',
					_0: A2(_terezka$elm_plot$Internal_Bars$getYValues, xValue, _p3._2),
					_1: yValues
				};
			default:
				return yValues;
		}
	});
var _terezka$elm_plot$Plot$getLastGetTickValues = function (axisConfigs) {
	return _terezka$elm_plot$Internal_Axis$getValues(
		function (_) {
			return _.tickValues;
		}(
			A2(
				_elm_lang$core$Maybe$withDefault,
				_terezka$elm_plot$Internal_Axis$defaultConfigX,
				_elm_lang$core$List$head(axisConfigs))));
};
var _terezka$elm_plot$Plot$foldAxisConfigs = F2(
	function (element, axisConfigs) {
		var _p4 = element;
		if (_p4.ctor === 'Axis') {
			return A3(
				_terezka$elm_plot$Internal_Stuff$foldOriented,
				function (configs) {
					return {ctor: '::', _0: _p4._0, _1: configs};
				},
				_p4._0.orientation,
				axisConfigs);
		} else {
			return axisConfigs;
		}
	});
var _terezka$elm_plot$Plot$toAxisConfigsOriented = A2(
	_elm_lang$core$List$foldr,
	_terezka$elm_plot$Plot$foldAxisConfigs,
	{
		x: {ctor: '[]'},
		y: {ctor: '[]'}
	});
var _terezka$elm_plot$Plot$getHintInfo = F2(
	function (elements, xValue) {
		return A2(
			_terezka$elm_plot$Plot_Hint$HintInfo,
			xValue,
			A3(
				_elm_lang$core$List$foldr,
				_terezka$elm_plot$Plot$collectYValues(xValue),
				{ctor: '[]'},
				elements));
	});
var _terezka$elm_plot$Plot$flipMeta = function (_p5) {
	var _p6 = _p5;
	return _elm_lang$core$Native_Utils.update(
		_p6,
		{
			scale: _terezka$elm_plot$Internal_Stuff$flipOriented(_p6.scale),
			toSvgCoords: _p6.oppositeToSvgCoords,
			oppositeToSvgCoords: _p6.toSvgCoords,
			axisCrossings: _p6.oppositeAxisCrossings,
			oppositeAxisCrossings: _p6.axisCrossings,
			ticks: _p6.oppositeTicks,
			oppositeTicks: _p6.ticks
		});
};
var _terezka$elm_plot$Plot$getFlippedMeta = F2(
	function (orientation, meta) {
		var _p7 = orientation;
		if (_p7.ctor === 'X') {
			return meta;
		} else {
			return _terezka$elm_plot$Plot$flipMeta(meta);
		}
	});
var _terezka$elm_plot$Plot$updateInternalBounds = F2(
	function (old, $new) {
		return _elm_lang$core$Maybe$Just(
			A2(_terezka$elm_plot$Internal_Stuff$foldBounds, old, $new));
	});
var _terezka$elm_plot$Plot$foldInternalBoundsBars = F3(
	function (config, groups, bounds) {
		var allBarPoints = A2(_terezka$elm_plot$Internal_Bars$toPoints, config, groups);
		var _p8 = _elm_lang$core$List$unzip(allBarPoints);
		var allBarXValues = _p8._0;
		var newXBounds = A2(
			_terezka$elm_plot$Plot$updateInternalBounds,
			bounds.x,
			{
				lower: _terezka$elm_plot$Internal_Stuff$getLowest(allBarXValues) - 0.5,
				upper: _terezka$elm_plot$Internal_Stuff$getHighest(allBarXValues) + 0.5
			});
		return _elm_lang$core$Native_Utils.update(
			bounds,
			{x: newXBounds});
	});
var _terezka$elm_plot$Plot$foldInternalBoundsArea = function (bounds) {
	return _elm_lang$core$Native_Utils.update(
		bounds,
		{
			y: _elm_lang$core$Maybe$Just(
				A2(
					_terezka$elm_plot$Internal_Stuff$foldBounds,
					bounds.y,
					{lower: 0, upper: 0}))
		});
};
var _terezka$elm_plot$Plot$foldInternalBounds = function (element) {
	var _p9 = element;
	switch (_p9.ctor) {
		case 'Area':
			return _terezka$elm_plot$Plot$foldInternalBoundsArea;
		case 'Bars':
			return function (_p10) {
				return _terezka$elm_plot$Plot$foldInternalBoundsArea(
					A3(_terezka$elm_plot$Plot$foldInternalBoundsBars, _p9._0, _p9._2, _p10));
			};
		default:
			return _elm_lang$core$Basics$identity;
	}
};
var _terezka$elm_plot$Plot$foldPoints = F2(
	function (element, allPoints) {
		var _p11 = element;
		switch (_p11.ctor) {
			case 'Area':
				return A2(_elm_lang$core$Basics_ops['++'], allPoints, _p11._1);
			case 'Line':
				return A2(_elm_lang$core$Basics_ops['++'], allPoints, _p11._1);
			case 'Scatter':
				return A2(_elm_lang$core$Basics_ops['++'], allPoints, _p11._1);
			case 'Bars':
				return A2(
					_elm_lang$core$Basics_ops['++'],
					allPoints,
					A2(_terezka$elm_plot$Internal_Bars$toPoints, _p11._0, _p11._2));
			default:
				return allPoints;
		}
	});
var _terezka$elm_plot$Plot$toValuesOriented = function (elements) {
	return function (_p12) {
		var _p13 = _p12;
		return A2(_terezka$elm_plot$Internal_Types$Oriented, _p13._0, _p13._1);
	}(
		_elm_lang$core$List$unzip(
			A3(
				_elm_lang$core$List$foldr,
				_terezka$elm_plot$Plot$foldPoints,
				{ctor: '[]'},
				elements)));
};
var _terezka$elm_plot$Plot$calculateMeta = F2(
	function (_p14, elements) {
		var _p15 = _p14;
		var _p17 = _p15.size;
		var _p16 = _p15.margin;
		var top = _p16._0;
		var right = _p16._1;
		var bottom = _p16._2;
		var left = _p16._3;
		var axisConfigs = _terezka$elm_plot$Plot$toAxisConfigsOriented(elements);
		var internalBounds = A3(
			_elm_lang$core$List$foldl,
			_terezka$elm_plot$Plot$foldInternalBounds,
			A2(_terezka$elm_plot$Internal_Types$Oriented, _elm_lang$core$Maybe$Nothing, _elm_lang$core$Maybe$Nothing),
			elements);
		var values = _terezka$elm_plot$Plot$toValuesOriented(elements);
		var xScale = A6(
			_terezka$elm_plot$Internal_Scale$getScale,
			_p17.x,
			_p15.range,
			internalBounds.x,
			A2(_terezka$elm_plot$Internal_Types$Edges, left, right),
			{ctor: '_Tuple2', _0: 0, _1: 0},
			values.x);
		var xTicks = A2(_terezka$elm_plot$Plot$getLastGetTickValues, axisConfigs.x, xScale);
		var yScale = A6(
			_terezka$elm_plot$Internal_Scale$getScale,
			_p17.y,
			_p15.domain,
			internalBounds.y,
			A2(_terezka$elm_plot$Internal_Types$Edges, top, bottom),
			_p15.padding,
			values.y);
		var yTicks = A2(_terezka$elm_plot$Plot$getLastGetTickValues, axisConfigs.y, yScale);
		return {
			scale: A2(_terezka$elm_plot$Internal_Types$Oriented, xScale, yScale),
			toSvgCoords: A2(_terezka$elm_plot$Internal_Scale$toSvgCoordsX, xScale, yScale),
			oppositeToSvgCoords: A2(_terezka$elm_plot$Internal_Scale$toSvgCoordsY, xScale, yScale),
			fromSvgCoords: A2(_terezka$elm_plot$Internal_Scale$fromSvgCoords, xScale, yScale),
			ticks: xTicks,
			oppositeTicks: yTicks,
			axisCrossings: A2(_terezka$elm_plot$Plot$getAxisCrossings, axisConfigs.x, yScale),
			oppositeAxisCrossings: A2(_terezka$elm_plot$Plot$getAxisCrossings, axisConfigs.y, xScale),
			toNearestX: _terezka$elm_plot$Internal_Stuff$toNearest(values.x),
			getHintInfo: _terezka$elm_plot$Plot$getHintInfo(elements),
			id: _p15.id
		};
	});
var _terezka$elm_plot$Plot$viewElement = F3(
	function (meta, element, _p18) {
		var _p19 = _p18;
		var _p23 = _p19._0;
		var _p22 = _p19._1;
		var _p20 = element;
		switch (_p20.ctor) {
			case 'Line':
				return {
					ctor: '_Tuple2',
					_0: {
						ctor: '::',
						_0: A3(_terezka$elm_plot$Internal_Line$view, meta, _p20._0, _p20._1),
						_1: _p23
					},
					_1: _p22
				};
			case 'Area':
				return {
					ctor: '_Tuple2',
					_0: {
						ctor: '::',
						_0: A3(_terezka$elm_plot$Internal_Area$view, meta, _p20._0, _p20._1),
						_1: _p23
					},
					_1: _p22
				};
			case 'Scatter':
				return {
					ctor: '_Tuple2',
					_0: {
						ctor: '::',
						_0: A3(_terezka$elm_plot$Internal_Scatter$view, meta, _p20._0, _p20._1),
						_1: _p23
					},
					_1: _p22
				};
			case 'Bars':
				return {
					ctor: '_Tuple2',
					_0: {
						ctor: '::',
						_0: A4(_terezka$elm_plot$Internal_Bars$view, meta, _p20._0, _p20._1, _p20._2),
						_1: _p23
					},
					_1: _p22
				};
			case 'Axis':
				return {
					ctor: '_Tuple2',
					_0: {
						ctor: '::',
						_0: A2(
							_terezka$elm_plot$Internal_Axis$view,
							A2(_terezka$elm_plot$Plot$getFlippedMeta, _p20._0.orientation, meta),
							_p20._0),
						_1: _p23
					},
					_1: _p22
				};
			case 'Grid':
				return {
					ctor: '_Tuple2',
					_0: {
						ctor: '::',
						_0: A2(
							_terezka$elm_plot$Internal_Grid$view,
							A2(_terezka$elm_plot$Plot$getFlippedMeta, _p20._0.orientation, meta),
							_p20._0),
						_1: _p23
					},
					_1: _p22
				};
			case 'CustomElement':
				return {
					ctor: '_Tuple2',
					_0: {
						ctor: '::',
						_0: _p20._0(meta.toSvgCoords),
						_1: _p23
					},
					_1: _p22
				};
			default:
				var _p21 = _p20._1;
				if (_p21.ctor === 'Just') {
					return {
						ctor: '_Tuple2',
						_0: _p23,
						_1: {
							ctor: '::',
							_0: A3(_terezka$elm_plot$Internal_Hint$view, meta, _p20._0, _p21._0),
							_1: _p22
						}
					};
				} else {
					return {ctor: '_Tuple2', _0: _p23, _1: _p22};
				}
		}
	});
var _terezka$elm_plot$Plot$viewElements = F2(
	function (meta, elements) {
		return A3(
			_elm_lang$core$List$foldr,
			_terezka$elm_plot$Plot$viewElement(meta),
			{
				ctor: '_Tuple2',
				_0: {ctor: '[]'},
				_1: {ctor: '[]'}
			},
			elements);
	});
var _terezka$elm_plot$Plot$sizeStyle = function (_p24) {
	var _p25 = _p24;
	return {
		ctor: '::',
		_0: {
			ctor: '_Tuple2',
			_0: 'height',
			_1: _terezka$elm_plot$Internal_Draw$toPixels(_p25.y)
		},
		_1: {
			ctor: '::',
			_0: {
				ctor: '_Tuple2',
				_0: 'width',
				_1: _terezka$elm_plot$Internal_Draw$toPixels(_p25.x)
			},
			_1: {ctor: '[]'}
		}
	};
};
var _terezka$elm_plot$Plot$viewSvg = F2(
	function (_p26, views) {
		var _p27 = _p26;
		return A2(
			_elm_lang$svg$Svg$svg,
			{
				ctor: '::',
				_0: _elm_lang$svg$Svg_Attributes$height(
					_elm_lang$core$Basics$toString(_p27.y)),
				_1: {
					ctor: '::',
					_0: _elm_lang$svg$Svg_Attributes$width(
						_elm_lang$core$Basics$toString(_p27.x)),
					_1: {
						ctor: '::',
						_0: _elm_lang$svg$Svg_Attributes$class('elm-plot__inner'),
						_1: {ctor: '[]'}
					}
				}
			},
			views);
	});
var _terezka$elm_plot$Plot$plotAttributes = function (_p28) {
	var _p29 = _p28;
	return {
		ctor: '::',
		_0: _elm_lang$html$Html_Attributes$class('elm-plot'),
		_1: {
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$style(
				A2(
					_elm_lang$core$Basics_ops['++'],
					_terezka$elm_plot$Plot$sizeStyle(_p29.size),
					_p29.style)),
			_1: {
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$id(_p29.id),
				_1: {ctor: '[]'}
			}
		}
	};
};
var _terezka$elm_plot$Plot$viewPlot = F3(
	function (_p31, meta, _p30) {
		var _p32 = _p31;
		var _p33 = _p30;
		return A2(
			_elm_lang$html$Html$div,
			_terezka$elm_plot$Plot$plotAttributes(_p32),
			{
				ctor: '::',
				_0: A2(_terezka$elm_plot$Plot$viewSvg, _p32.size, _p33._0),
				_1: _p33._1
			});
	});
var _terezka$elm_plot$Plot$parsePlot = F2(
	function (config, elements) {
		var meta = A2(_terezka$elm_plot$Plot$calculateMeta, config, elements);
		return A3(
			_terezka$elm_plot$Plot$viewPlot,
			config,
			meta,
			A2(_terezka$elm_plot$Plot$viewElements, meta, elements));
	});
var _terezka$elm_plot$Plot$getPosition = A2(
	_elm_lang$core$Json_Decode$map,
	function (_p34) {
		var _p35 = _p34;
		return {ctor: '_Tuple2', _0: _p35.left, _1: _p35.top};
	},
	_debois$elm_dom$DOM$boundingClientRect);
var _terezka$elm_plot$Plot$getPlotPosition = _elm_lang$core$Json_Decode$oneOf(
	{
		ctor: '::',
		_0: _terezka$elm_plot$Plot$getPosition,
		_1: {
			ctor: '::',
			_0: _elm_lang$core$Json_Decode$lazy(
				function (_p36) {
					return _terezka$elm_plot$Plot$getParentPosition;
				}),
			_1: {ctor: '[]'}
		}
	});
var _terezka$elm_plot$Plot$getParentPosition = _debois$elm_dom$DOM$parentElement(_terezka$elm_plot$Plot$getPlotPosition);
var _terezka$elm_plot$Plot$getRelativePosition = F3(
	function (_p39, _p38, _p37) {
		var _p40 = _p39;
		var _p41 = _p38;
		var _p42 = _p37;
		var _p43 = _p40.fromSvgCoords(
			{ctor: '_Tuple2', _0: _p41._0 - _p42._0, _1: _p41._1 - _p42._1});
		var x = _p43._0;
		var y = _p43._1;
		return {
			ctor: '_Tuple2',
			_0: _p40.toNearestX(x),
			_1: y
		};
	});
var _terezka$elm_plot$Plot$shouldPositionUpdate = F2(
	function (_p45, _p44) {
		var _p46 = _p45;
		var _p47 = _p44;
		var _p48 = _p46.position;
		if (_p48.ctor === 'Nothing') {
			return true;
		} else {
			return (!_elm_lang$core$Native_Utils.eq(_p48._0._1, _p47._1)) || (!_elm_lang$core$Native_Utils.eq(_p48._0._0, _p47._0));
		}
	});
var _terezka$elm_plot$Plot$getHoveredValue = function (_p49) {
	var _p50 = _p49;
	return _p50._0.position;
};
var _terezka$elm_plot$Plot$rangeHighest = F2(
	function (toHighest, _p51) {
		var _p52 = _p51;
		return _elm_lang$core$Native_Utils.update(
			_p52,
			{
				range: _elm_lang$core$Native_Utils.update(
					_p52.range,
					{upper: toHighest})
			});
	});
var _terezka$elm_plot$Plot$rangeLowest = F2(
	function (toLowest, _p53) {
		var _p54 = _p53;
		return _elm_lang$core$Native_Utils.update(
			_p54,
			{
				range: _elm_lang$core$Native_Utils.update(
					_p54.range,
					{lower: toLowest})
			});
	});
var _terezka$elm_plot$Plot$domainHighest = F2(
	function (toHighest, _p55) {
		var _p56 = _p55;
		return _elm_lang$core$Native_Utils.update(
			_p56,
			{
				domain: _elm_lang$core$Native_Utils.update(
					_p56.domain,
					{upper: toHighest})
			});
	});
var _terezka$elm_plot$Plot$domainLowest = F2(
	function (toLowest, _p57) {
		var _p58 = _p57;
		return _elm_lang$core$Native_Utils.update(
			_p58,
			{
				domain: _elm_lang$core$Native_Utils.update(
					_p58.domain,
					{lower: toLowest})
			});
	});
var _terezka$elm_plot$Plot$id = F2(
	function (id, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{id: id});
	});
var _terezka$elm_plot$Plot$classes = F2(
	function (classes, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{classes: classes});
	});
var _terezka$elm_plot$Plot$margin = F2(
	function (_p59, config) {
		var _p60 = _p59;
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				margin: {
					ctor: '_Tuple4',
					_0: _elm_lang$core$Basics$toFloat(_p60._0),
					_1: _elm_lang$core$Basics$toFloat(_p60._1),
					_2: _elm_lang$core$Basics$toFloat(_p60._2),
					_3: _elm_lang$core$Basics$toFloat(_p60._3)
				}
			});
	});
var _terezka$elm_plot$Plot$size = F2(
	function (_p61, config) {
		var _p62 = _p61;
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				size: A2(
					_terezka$elm_plot$Internal_Types$Oriented,
					_elm_lang$core$Basics$toFloat(_p62._0),
					_elm_lang$core$Basics$toFloat(_p62._1))
			});
	});
var _terezka$elm_plot$Plot$padding = F2(
	function (_p63, config) {
		var _p64 = _p63;
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				padding: {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Basics$toFloat(_p64._0),
					_1: _elm_lang$core$Basics$toFloat(_p64._1)
				}
			});
	});
var _terezka$elm_plot$Plot$defaultConfig = {
	size: A2(_terezka$elm_plot$Internal_Types$Oriented, 800, 500),
	padding: {ctor: '_Tuple2', _0: 0, _1: 0},
	margin: {ctor: '_Tuple4', _0: 0, _1: 0, _2: 0, _3: 0},
	classes: {ctor: '[]'},
	style: {ctor: '[]'},
	domain: A2(_terezka$elm_plot$Internal_Types$EdgesAny, _elm_lang$core$Basics$identity, _elm_lang$core$Basics$identity),
	range: A2(_terezka$elm_plot$Internal_Types$EdgesAny, _elm_lang$core$Basics$identity, _elm_lang$core$Basics$identity),
	id: 'elm-plot'
};
var _terezka$elm_plot$Plot$style = F2(
	function (style, config) {
		return _elm_lang$core$Native_Utils.update(
			config,
			{
				style: A2(
					_elm_lang$core$Basics_ops['++'],
					_terezka$elm_plot$Plot$defaultConfig.style,
					A2(
						_elm_lang$core$Basics_ops['++'],
						style,
						{
							ctor: '::',
							_0: {ctor: '_Tuple2', _0: 'padding', _1: '0'},
							_1: {ctor: '[]'}
						}))
			});
	});
var _terezka$elm_plot$Plot$toPlotConfig = A2(
	_elm_lang$core$List$foldl,
	F2(
		function (x, y) {
			return x(y);
		}),
	_terezka$elm_plot$Plot$defaultConfig);
var _terezka$elm_plot$Plot$plot = function (attrs) {
	return A2(
		_elm_lang$svg$Svg_Lazy$lazy2,
		_terezka$elm_plot$Plot$parsePlot,
		_terezka$elm_plot$Plot$toPlotConfig(attrs));
};
var _terezka$elm_plot$Plot$Config = F8(
	function (a, b, c, d, e, f, g, h) {
		return {size: a, padding: b, margin: c, classes: d, style: e, domain: f, range: g, id: h};
	});
var _terezka$elm_plot$Plot$StateInner = function (a) {
	return {position: a};
};
var _terezka$elm_plot$Plot$CustomElement = function (a) {
	return {ctor: 'CustomElement', _0: a};
};
var _terezka$elm_plot$Plot$custom = function (view) {
	return _terezka$elm_plot$Plot$CustomElement(view);
};
var _terezka$elm_plot$Plot$Grid = function (a) {
	return {ctor: 'Grid', _0: a};
};
var _terezka$elm_plot$Plot$horizontalGrid = function (attrs) {
	return _terezka$elm_plot$Plot$Grid(
		A3(
			_elm_lang$core$List$foldr,
			F2(
				function (x, y) {
					return x(y);
				}),
			_terezka$elm_plot$Internal_Grid$defaultConfigX,
			attrs));
};
var _terezka$elm_plot$Plot$verticalGrid = function (attrs) {
	return _terezka$elm_plot$Plot$Grid(
		A3(
			_elm_lang$core$List$foldr,
			F2(
				function (x, y) {
					return x(y);
				}),
			_terezka$elm_plot$Internal_Grid$defaultConfigY,
			attrs));
};
var _terezka$elm_plot$Plot$Axis = function (a) {
	return {ctor: 'Axis', _0: a};
};
var _terezka$elm_plot$Plot$xAxis = function (attrs) {
	return _terezka$elm_plot$Plot$Axis(
		A3(
			_elm_lang$core$List$foldl,
			F2(
				function (x, y) {
					return x(y);
				}),
			_terezka$elm_plot$Internal_Axis$defaultConfigX,
			attrs));
};
var _terezka$elm_plot$Plot$yAxis = function (attrs) {
	return _terezka$elm_plot$Plot$Axis(
		A3(
			_elm_lang$core$List$foldl,
			F2(
				function (x, y) {
					return x(y);
				}),
			_terezka$elm_plot$Internal_Axis$defaultConfigY,
			attrs));
};
var _terezka$elm_plot$Plot$Hint = F2(
	function (a, b) {
		return {ctor: 'Hint', _0: a, _1: b};
	});
var _terezka$elm_plot$Plot$hint = F2(
	function (attrs, position) {
		return A2(
			_terezka$elm_plot$Plot$Hint,
			A3(
				_elm_lang$core$List$foldr,
				F2(
					function (x, y) {
						return x(y);
					}),
				_terezka$elm_plot$Internal_Hint$defaultConfig,
				attrs),
			position);
	});
var _terezka$elm_plot$Plot$Scatter = F2(
	function (a, b) {
		return {ctor: 'Scatter', _0: a, _1: b};
	});
var _terezka$elm_plot$Plot$scatter = function (attrs) {
	return _terezka$elm_plot$Plot$Scatter(
		A3(
			_elm_lang$core$List$foldr,
			F2(
				function (x, y) {
					return x(y);
				}),
			_terezka$elm_plot$Internal_Scatter$defaultConfig,
			attrs));
};
var _terezka$elm_plot$Plot$Bars = F3(
	function (a, b, c) {
		return {ctor: 'Bars', _0: a, _1: b, _2: c};
	});
var _terezka$elm_plot$Plot$bars = F3(
	function (attrs, styleAttrsList, groups) {
		return A3(
			_terezka$elm_plot$Plot$Bars,
			A3(
				_elm_lang$core$List$foldr,
				F2(
					function (x, y) {
						return x(y);
					}),
				_terezka$elm_plot$Internal_Bars$defaultConfig,
				attrs),
			A2(
				_elm_lang$core$List$map,
				A2(
					_elm_lang$core$List$foldr,
					F2(
						function (x, y) {
							return x(y);
						}),
					_terezka$elm_plot$Internal_Bars$defaultStyleConfig),
				styleAttrsList),
			groups);
	});
var _terezka$elm_plot$Plot$Area = F2(
	function (a, b) {
		return {ctor: 'Area', _0: a, _1: b};
	});
var _terezka$elm_plot$Plot$area = F2(
	function (attrs, points) {
		return A2(
			_terezka$elm_plot$Plot$Area,
			A3(
				_elm_lang$core$List$foldr,
				F2(
					function (x, y) {
						return x(y);
					}),
				_terezka$elm_plot$Internal_Area$defaultConfig,
				attrs),
			points);
	});
var _terezka$elm_plot$Plot$Line = F2(
	function (a, b) {
		return {ctor: 'Line', _0: a, _1: b};
	});
var _terezka$elm_plot$Plot$line = F2(
	function (attrs, points) {
		return A2(
			_terezka$elm_plot$Plot$Line,
			A3(
				_elm_lang$core$List$foldr,
				F2(
					function (x, y) {
						return x(y);
					}),
				_terezka$elm_plot$Internal_Line$defaultConfig,
				attrs),
			points);
	});
var _terezka$elm_plot$Plot$State = function (a) {
	return {ctor: 'State', _0: a};
};
var _terezka$elm_plot$Plot$initialState = _terezka$elm_plot$Plot$State(
	{position: _elm_lang$core$Maybe$Nothing});
var _terezka$elm_plot$Plot$update = F2(
	function (msg, _p65) {
		var _p66 = _p65;
		var _p69 = _p66._0;
		var _p67 = msg;
		if (_p67.ctor === 'Hovering') {
			var _p68 = _p67._0;
			return A2(_terezka$elm_plot$Plot$shouldPositionUpdate, _p69, _p68) ? _terezka$elm_plot$Plot$State(
				_elm_lang$core$Native_Utils.update(
					_p69,
					{
						position: _elm_lang$core$Maybe$Just(_p68)
					})) : _terezka$elm_plot$Plot$State(_p69);
		} else {
			return _terezka$elm_plot$Plot$State(
				{position: _elm_lang$core$Maybe$Nothing});
		}
	});
var _terezka$elm_plot$Plot$Custom = function (a) {
	return {ctor: 'Custom', _0: a};
};
var _terezka$elm_plot$Plot$Internal = function (a) {
	return {ctor: 'Internal', _0: a};
};
var _terezka$elm_plot$Plot$ResetPosition = {ctor: 'ResetPosition'};
var _terezka$elm_plot$Plot$Hovering = function (a) {
	return {ctor: 'Hovering', _0: a};
};
var _terezka$elm_plot$Plot$toMouseOverMsg = F4(
	function (meta, mouseX, mouseY, position) {
		var relativePosition = A3(
			_terezka$elm_plot$Plot$getRelativePosition,
			meta,
			{ctor: '_Tuple2', _0: mouseX, _1: mouseY},
			position);
		var _p70 = _elm_lang$core$Tuple$first(relativePosition);
		if (_p70.ctor === 'Just') {
			return _terezka$elm_plot$Plot$Internal(
				_terezka$elm_plot$Plot$Hovering(
					{
						ctor: '_Tuple2',
						_0: _p70._0,
						_1: _elm_lang$core$Tuple$second(relativePosition)
					}));
		} else {
			return _terezka$elm_plot$Plot$Internal(_terezka$elm_plot$Plot$ResetPosition);
		}
	});
var _terezka$elm_plot$Plot$handleMouseOver = function (meta) {
	return A4(
		_elm_lang$core$Json_Decode$map3,
		_terezka$elm_plot$Plot$toMouseOverMsg(meta),
		A2(_elm_lang$core$Json_Decode$field, 'clientX', _elm_lang$core$Json_Decode$float),
		A2(_elm_lang$core$Json_Decode$field, 'clientY', _elm_lang$core$Json_Decode$float),
		_debois$elm_dom$DOM$target(_terezka$elm_plot$Plot$getPlotPosition));
};
var _terezka$elm_plot$Plot$plotAttributesInteraction = function (meta) {
	return {
		ctor: '::',
		_0: A2(
			_elm_lang$html$Html_Events$on,
			'mousemove',
			_terezka$elm_plot$Plot$handleMouseOver(meta)),
		_1: {
			ctor: '::',
			_0: _elm_lang$html$Html_Events$onMouseLeave(
				_terezka$elm_plot$Plot$Internal(_terezka$elm_plot$Plot$ResetPosition)),
			_1: {ctor: '[]'}
		}
	};
};
var _terezka$elm_plot$Plot$viewPlotInteractive = F3(
	function (_p72, meta, _p71) {
		var _p73 = _p72;
		var _p74 = _p71;
		return A2(
			_elm_lang$html$Html$div,
			A2(
				_elm_lang$core$Basics_ops['++'],
				_terezka$elm_plot$Plot$plotAttributes(_p73),
				_terezka$elm_plot$Plot$plotAttributesInteraction(meta)),
			{
				ctor: '::',
				_0: A2(_terezka$elm_plot$Plot$viewSvg, _p73.size, _p74._0),
				_1: _p74._1
			});
	});
var _terezka$elm_plot$Plot$parsePlotInteractive = F2(
	function (config, elements) {
		var meta = A2(_terezka$elm_plot$Plot$calculateMeta, config, elements);
		return A3(
			_terezka$elm_plot$Plot$viewPlotInteractive,
			config,
			meta,
			A2(_terezka$elm_plot$Plot$viewElements, meta, elements));
	});
var _terezka$elm_plot$Plot$plotInteractive = function (attrs) {
	return A2(
		_elm_lang$svg$Svg_Lazy$lazy2,
		_terezka$elm_plot$Plot$parsePlotInteractive,
		_terezka$elm_plot$Plot$toPlotConfig(attrs));
};

var _terezka$elm_plot$Common$pinkStroke = '#ff9edf';
var _terezka$elm_plot$Common$pinkFill = '#fdb9e7';
var _terezka$elm_plot$Common$skinStroke = '#f7e0d2';
var _terezka$elm_plot$Common$skinFill = '#feefe5';
var _terezka$elm_plot$Common$blueStroke = '#cfd8ea';
var _terezka$elm_plot$Common$blueFill = '#e4eeff';
var _terezka$elm_plot$Common$axisColorLight = '#e4e4e4';
var _terezka$elm_plot$Common$axisColor = '#949494';
var _terezka$elm_plot$Common$plotSize = {ctor: '_Tuple2', _0: 600, _1: 300};
var _terezka$elm_plot$Common$PlotExample = F4(
	function (a, b, c, d) {
		return {title: a, id: b, view: c, code: d};
	});
var _terezka$elm_plot$Common$ViewInteractive = F2(
	function (a, b) {
		return {ctor: 'ViewInteractive', _0: a, _1: b};
	});
var _terezka$elm_plot$Common$ViewStatic = function (a) {
	return {ctor: 'ViewStatic', _0: a};
};

var _terezka$elm_plot$PlotComposed$code = '\n    isOdd : Int -> Bool\n    isOdd n =\n        rem n 2 > 0\n\n\n    filterLabels : Axis.LabelInfo -> Bool\n    filterLabels { index } =\n        not (isOdd index)\n\n\n    toTickStyle : Axis.LabelInfo -> List (Tick.StyleAttribute msg)\n    toTickStyle { index } =\n        if isOdd index then\n            [ Tick.length 7\n            , Tick.stroke \"#e4e3e3\"\n            ]\n        else\n            [ Tick.length 10\n            , Tick.stroke \"#b9b9b9\"\n            ]\n\n\n    labelStyle : List (Label.StyleAttribute msg)\n    labelStyle =\n        [ Label.fontSize 12\n        , Label.displace ( 0, -2 )\n        ]\n\n\n    view : State -> Svg.Svg (Interaction c)\n    view state =\n        plotInteractive\n            [ size ( 800, 400 )\n            , padding ( 40, 40 )\n            , margin ( 15, 20, 40, 15 )\n            ]\n            [ horizontalGrid\n                [ Grid.lines [ Line.stroke \"#f2f2f2\" ] ]\n            , verticalGrid\n                [ Grid.lines [ Line.stroke \"#f2f2f2\" ] ]\n            , area\n                [ Area.stroke skinStroke\n                , Area.fill skinFill\n                , Area.opacity 0.5\n                ]\n                data1\n            , area\n                [ Area.stroke blueStroke\n                , Area.fill blueFill\n                ]\n                data1\n            , line\n                [ Line.stroke pinkStroke\n                , Line.strokeWidth 2\n                ]\n                data2\n            , scatter\n                []\n                data3\n            , yAxis\n                [ Axis.anchorInside\n                , Axis.cleanCrossings\n                , Axis.positionLowest\n                , Axis.line\n                    [ Line.stroke \"#b9b9b9\" ]\n                , Axis.tickDelta 50\n                , Axis.label\n                    [ Label.view labelStyle\n                    , Label.format (\\{ value } -> toString value ++ \" °C\")\n                    ]\n                ]\n            , xAxis\n                [ Axis.cleanCrossings\n                , Axis.line\n                    [ Line.stroke \"#b9b9b9\" ]\n                , Axis.tickDelta 2.5\n                , Axis.tick\n                    [ Tick.viewDynamic toTickStyle ]\n                , Axis.label\n                    [ Label.view\n                        [ Label.fontSize 12\n                        , Label.stroke \"#b9b9b9\"\n                        ]\n                    , Label.format (\\{ value } -> toString value ++ \" x\")\n                    ]\n                ]\n            , xAxis\n                [ Axis.positionLowest\n                , Axis.line [ Line.stroke \"#b9b9b9\" ]\n                , Axis.tick\n                    [ Tick.viewDynamic toTickStyle ]\n                , Axis.label\n                    [ Label.view\n                        [ Label.fontSize 12\n                        , Label.stroke \"#b9b9b9\"\n                        ]\n                    , Label.format\n                        (\\{ value, index } ->\n                            if isOdd index then\n                                \"\"\n                            else\n                                toString value ++ \" t\"\n                        )\n                    ]\n                ]\n            , hint\n                [ Hint.lineStyle [ ( \"background\", \"#b9b9b9\" ) ] ]\n                (getHoveredValue state)\n            ]\n    ';
var _terezka$elm_plot$PlotComposed$labelStyle = {
	ctor: '::',
	_0: _terezka$elm_plot$Plot_Label$fontSize(12),
	_1: {
		ctor: '::',
		_0: _terezka$elm_plot$Plot_Label$displace(
			{ctor: '_Tuple2', _0: 0, _1: -2}),
		_1: {ctor: '[]'}
	}
};
var _terezka$elm_plot$PlotComposed$isOdd = function (n) {
	return _elm_lang$core$Native_Utils.cmp(
		A2(_elm_lang$core$Basics$rem, n, 2),
		0) > 0;
};
var _terezka$elm_plot$PlotComposed$filterLabels = function (_p0) {
	var _p1 = _p0;
	return !_terezka$elm_plot$PlotComposed$isOdd(_p1.index);
};
var _terezka$elm_plot$PlotComposed$toTickStyle = function (_p2) {
	var _p3 = _p2;
	return _terezka$elm_plot$PlotComposed$isOdd(_p3.index) ? {
		ctor: '::',
		_0: _terezka$elm_plot$Plot_Tick$length(7),
		_1: {
			ctor: '::',
			_0: _terezka$elm_plot$Plot_Tick$stroke('#e4e3e3'),
			_1: {ctor: '[]'}
		}
	} : {
		ctor: '::',
		_0: _terezka$elm_plot$Plot_Tick$length(10),
		_1: {
			ctor: '::',
			_0: _terezka$elm_plot$Plot_Tick$stroke('#b9b9b9'),
			_1: {ctor: '[]'}
		}
	};
};
var _terezka$elm_plot$PlotComposed$dataScat = {
	ctor: '::',
	_0: {ctor: '_Tuple2', _0: -8, _1: 50},
	_1: {
		ctor: '::',
		_0: {ctor: '_Tuple2', _0: -7, _1: 45},
		_1: {
			ctor: '::',
			_0: {ctor: '_Tuple2', _0: -6.5, _1: 70},
			_1: {
				ctor: '::',
				_0: {ctor: '_Tuple2', _0: -6, _1: 90},
				_1: {
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: -4, _1: 81},
					_1: {
						ctor: '::',
						_0: {ctor: '_Tuple2', _0: -3, _1: 106},
						_1: {
							ctor: '::',
							_0: {ctor: '_Tuple2', _0: -1, _1: 115},
							_1: {
								ctor: '::',
								_0: {ctor: '_Tuple2', _0: 0, _1: 140},
								_1: {ctor: '[]'}
							}
						}
					}
				}
			}
		}
	}
};
var _terezka$elm_plot$PlotComposed$data1 = {
	ctor: '::',
	_0: {ctor: '_Tuple2', _0: -10, _1: 14},
	_1: {
		ctor: '::',
		_0: {ctor: '_Tuple2', _0: -9, _1: 5},
		_1: {
			ctor: '::',
			_0: {ctor: '_Tuple2', _0: -8, _1: -9},
			_1: {
				ctor: '::',
				_0: {ctor: '_Tuple2', _0: -7, _1: -15},
				_1: {
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: -6, _1: -22},
					_1: {
						ctor: '::',
						_0: {ctor: '_Tuple2', _0: -5, _1: -12},
						_1: {
							ctor: '::',
							_0: {ctor: '_Tuple2', _0: -4, _1: -8},
							_1: {
								ctor: '::',
								_0: {ctor: '_Tuple2', _0: -3, _1: -1},
								_1: {
									ctor: '::',
									_0: {ctor: '_Tuple2', _0: -2, _1: 6},
									_1: {
										ctor: '::',
										_0: {ctor: '_Tuple2', _0: -1, _1: 10},
										_1: {
											ctor: '::',
											_0: {ctor: '_Tuple2', _0: 0, _1: 14},
											_1: {
												ctor: '::',
												_0: {ctor: '_Tuple2', _0: 1, _1: 16},
												_1: {
													ctor: '::',
													_0: {ctor: '_Tuple2', _0: 2, _1: 26},
													_1: {
														ctor: '::',
														_0: {ctor: '_Tuple2', _0: 3, _1: 32},
														_1: {
															ctor: '::',
															_0: {ctor: '_Tuple2', _0: 4, _1: 28},
															_1: {
																ctor: '::',
																_0: {ctor: '_Tuple2', _0: 5, _1: 32},
																_1: {
																	ctor: '::',
																	_0: {ctor: '_Tuple2', _0: 6, _1: 29},
																	_1: {
																		ctor: '::',
																		_0: {ctor: '_Tuple2', _0: 7, _1: 46},
																		_1: {
																			ctor: '::',
																			_0: {ctor: '_Tuple2', _0: 8, _1: 52},
																			_1: {
																				ctor: '::',
																				_0: {ctor: '_Tuple2', _0: 9, _1: 53},
																				_1: {
																					ctor: '::',
																					_0: {ctor: '_Tuple2', _0: 10, _1: 59},
																					_1: {ctor: '[]'}
																				}
																			}
																		}
																	}
																}
															}
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
};
var _terezka$elm_plot$PlotComposed$view = function (state) {
	return A2(
		_terezka$elm_plot$Plot$plotInteractive,
		{
			ctor: '::',
			_0: _terezka$elm_plot$Plot$size(
				{ctor: '_Tuple2', _0: 800, _1: 400}),
			_1: {
				ctor: '::',
				_0: _terezka$elm_plot$Plot$padding(
					{ctor: '_Tuple2', _0: 40, _1: 40}),
				_1: {
					ctor: '::',
					_0: _terezka$elm_plot$Plot$margin(
						{ctor: '_Tuple4', _0: 15, _1: 20, _2: 40, _3: 15}),
					_1: {ctor: '[]'}
				}
			}
		},
		{
			ctor: '::',
			_0: _terezka$elm_plot$Plot$horizontalGrid(
				{
					ctor: '::',
					_0: _terezka$elm_plot$Plot_Grid$lines(
						{
							ctor: '::',
							_0: _terezka$elm_plot$Plot_Line$stroke('#f2f2f2'),
							_1: {ctor: '[]'}
						}),
					_1: {ctor: '[]'}
				}),
			_1: {
				ctor: '::',
				_0: _terezka$elm_plot$Plot$verticalGrid(
					{
						ctor: '::',
						_0: _terezka$elm_plot$Plot_Grid$lines(
							{
								ctor: '::',
								_0: _terezka$elm_plot$Plot_Line$stroke('#f2f2f2'),
								_1: {ctor: '[]'}
							}),
						_1: {ctor: '[]'}
					}),
				_1: {
					ctor: '::',
					_0: A2(
						_terezka$elm_plot$Plot$area,
						{
							ctor: '::',
							_0: _terezka$elm_plot$Plot_Area$stroke(_terezka$elm_plot$Common$skinStroke),
							_1: {
								ctor: '::',
								_0: _terezka$elm_plot$Plot_Area$fill(_terezka$elm_plot$Common$skinFill),
								_1: {
									ctor: '::',
									_0: _terezka$elm_plot$Plot_Area$opacity(0.5),
									_1: {
										ctor: '::',
										_0: _terezka$elm_plot$Plot_Area$smoothingBezier,
										_1: {ctor: '[]'}
									}
								}
							}
						},
						A2(
							_elm_lang$core$List$map,
							function (_p4) {
								var _p5 = _p4;
								return {
									ctor: '_Tuple2',
									_0: _p5._0,
									_1: _elm_lang$core$Basics$toFloat(
										_elm_lang$core$Basics$round(_p5._1 * 2.1))
								};
							},
							_terezka$elm_plot$PlotComposed$data1)),
					_1: {
						ctor: '::',
						_0: A2(
							_terezka$elm_plot$Plot$area,
							{
								ctor: '::',
								_0: _terezka$elm_plot$Plot_Area$stroke(_terezka$elm_plot$Common$blueStroke),
								_1: {
									ctor: '::',
									_0: _terezka$elm_plot$Plot_Area$fill(_terezka$elm_plot$Common$blueFill),
									_1: {
										ctor: '::',
										_0: _terezka$elm_plot$Plot_Area$smoothingBezier,
										_1: {ctor: '[]'}
									}
								}
							},
							_terezka$elm_plot$PlotComposed$data1),
						_1: {
							ctor: '::',
							_0: A2(
								_terezka$elm_plot$Plot$line,
								{
									ctor: '::',
									_0: _terezka$elm_plot$Plot_Line$stroke(_terezka$elm_plot$Common$pinkStroke),
									_1: {
										ctor: '::',
										_0: _terezka$elm_plot$Plot_Line$smoothingBezier,
										_1: {
											ctor: '::',
											_0: _terezka$elm_plot$Plot_Line$strokeWidth(2),
											_1: {ctor: '[]'}
										}
									}
								},
								A2(
									_elm_lang$core$List$map,
									function (_p6) {
										var _p7 = _p6;
										return {
											ctor: '_Tuple2',
											_0: _p7._0,
											_1: _elm_lang$core$Basics$toFloat(
												_elm_lang$core$Basics$round(_p7._1) * 3)
										};
									},
									_terezka$elm_plot$PlotComposed$data1)),
							_1: {
								ctor: '::',
								_0: A2(
									_terezka$elm_plot$Plot$scatter,
									{ctor: '[]'},
									_terezka$elm_plot$PlotComposed$dataScat),
								_1: {
									ctor: '::',
									_0: _terezka$elm_plot$Plot$yAxis(
										{
											ctor: '::',
											_0: _terezka$elm_plot$Plot_Axis$anchorInside,
											_1: {
												ctor: '::',
												_0: _terezka$elm_plot$Plot_Axis$cleanCrossings,
												_1: {
													ctor: '::',
													_0: _terezka$elm_plot$Plot_Axis$positionLowest,
													_1: {
														ctor: '::',
														_0: _terezka$elm_plot$Plot_Axis$line(
															{
																ctor: '::',
																_0: _terezka$elm_plot$Plot_Line$stroke('#b9b9b9'),
																_1: {ctor: '[]'}
															}),
														_1: {
															ctor: '::',
															_0: _terezka$elm_plot$Plot_Axis$tickDelta(50),
															_1: {
																ctor: '::',
																_0: _terezka$elm_plot$Plot_Axis$label(
																	{
																		ctor: '::',
																		_0: _terezka$elm_plot$Plot_Label$view(_terezka$elm_plot$PlotComposed$labelStyle),
																		_1: {
																			ctor: '::',
																			_0: _terezka$elm_plot$Plot_Label$format(
																				function (_p8) {
																					var _p9 = _p8;
																					return A2(
																						_elm_lang$core$Basics_ops['++'],
																						_elm_lang$core$Basics$toString(_p9.value),
																						' °C');
																				}),
																			_1: {ctor: '[]'}
																		}
																	}),
																_1: {ctor: '[]'}
															}
														}
													}
												}
											}
										}),
									_1: {
										ctor: '::',
										_0: _terezka$elm_plot$Plot$xAxis(
											{
												ctor: '::',
												_0: _terezka$elm_plot$Plot_Axis$cleanCrossings,
												_1: {
													ctor: '::',
													_0: _terezka$elm_plot$Plot_Axis$line(
														{
															ctor: '::',
															_0: _terezka$elm_plot$Plot_Line$stroke('#b9b9b9'),
															_1: {ctor: '[]'}
														}),
													_1: {
														ctor: '::',
														_0: _terezka$elm_plot$Plot_Axis$tickDelta(2.5),
														_1: {
															ctor: '::',
															_0: _terezka$elm_plot$Plot_Axis$tick(
																{
																	ctor: '::',
																	_0: _terezka$elm_plot$Plot_Tick$viewDynamic(_terezka$elm_plot$PlotComposed$toTickStyle),
																	_1: {ctor: '[]'}
																}),
															_1: {
																ctor: '::',
																_0: _terezka$elm_plot$Plot_Axis$label(
																	{
																		ctor: '::',
																		_0: _terezka$elm_plot$Plot_Label$view(
																			{
																				ctor: '::',
																				_0: _terezka$elm_plot$Plot_Label$fontSize(12),
																				_1: {
																					ctor: '::',
																					_0: _terezka$elm_plot$Plot_Label$stroke('#b9b9b9'),
																					_1: {ctor: '[]'}
																				}
																			}),
																		_1: {
																			ctor: '::',
																			_0: _terezka$elm_plot$Plot_Label$format(
																				function (_p10) {
																					var _p11 = _p10;
																					return A2(
																						_elm_lang$core$Basics_ops['++'],
																						_elm_lang$core$Basics$toString(_p11.value),
																						' x');
																				}),
																			_1: {ctor: '[]'}
																		}
																	}),
																_1: {ctor: '[]'}
															}
														}
													}
												}
											}),
										_1: {
											ctor: '::',
											_0: _terezka$elm_plot$Plot$xAxis(
												{
													ctor: '::',
													_0: _terezka$elm_plot$Plot_Axis$positionLowest,
													_1: {
														ctor: '::',
														_0: _terezka$elm_plot$Plot_Axis$line(
															{
																ctor: '::',
																_0: _terezka$elm_plot$Plot_Line$stroke('#b9b9b9'),
																_1: {ctor: '[]'}
															}),
														_1: {
															ctor: '::',
															_0: _terezka$elm_plot$Plot_Axis$tick(
																{
																	ctor: '::',
																	_0: _terezka$elm_plot$Plot_Tick$viewDynamic(_terezka$elm_plot$PlotComposed$toTickStyle),
																	_1: {ctor: '[]'}
																}),
															_1: {
																ctor: '::',
																_0: _terezka$elm_plot$Plot_Axis$label(
																	{
																		ctor: '::',
																		_0: _terezka$elm_plot$Plot_Label$view(
																			{
																				ctor: '::',
																				_0: _terezka$elm_plot$Plot_Label$fontSize(12),
																				_1: {
																					ctor: '::',
																					_0: _terezka$elm_plot$Plot_Label$stroke('#b9b9b9'),
																					_1: {ctor: '[]'}
																				}
																			}),
																		_1: {
																			ctor: '::',
																			_0: _terezka$elm_plot$Plot_Label$format(
																				function (_p12) {
																					var _p13 = _p12;
																					return _terezka$elm_plot$PlotComposed$isOdd(_p13.index) ? '' : A2(
																						_elm_lang$core$Basics_ops['++'],
																						_elm_lang$core$Basics$toString(_p13.value),
																						' t');
																				}),
																			_1: {ctor: '[]'}
																		}
																	}),
																_1: {ctor: '[]'}
															}
														}
													}
												}),
											_1: {
												ctor: '::',
												_0: A2(
													_terezka$elm_plot$Plot$hint,
													{
														ctor: '::',
														_0: _terezka$elm_plot$Plot_Hint$lineStyle(
															{
																ctor: '::',
																_0: {ctor: '_Tuple2', _0: 'background', _1: '#b9b9b9'},
																_1: {ctor: '[]'}
															}),
														_1: {ctor: '[]'}
													},
													_terezka$elm_plot$Plot$getHoveredValue(state)),
												_1: {ctor: '[]'}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		});
};
var _terezka$elm_plot$PlotComposed$id = 'ComposedPlot';

var _terezka$elm_plot$PlotScatter$code = '\n    view : Svg.Svg a\n    view =\n        plot\n            [ size plotSize\n            , margin ( 10, 20, 40, 40 )\n            , domainLowest (min 0)\n            ]\n            [ scatter\n                [ Scatter.stroke pinkStroke\n                , Scatter.fill pinkFill\n                , Scatter.radius 8\n                ]\n                data\n            , xAxis\n                [ Axis.line\n                    [ Line.stroke axisColor ]\n                , Axis.tickDelta 2\n                ]\n            ]\n    ';
var _terezka$elm_plot$PlotScatter$data = {
	ctor: '::',
	_0: {ctor: '_Tuple2', _0: 0, _1: 10},
	_1: {
		ctor: '::',
		_0: {ctor: '_Tuple2', _0: 2, _1: 12},
		_1: {
			ctor: '::',
			_0: {ctor: '_Tuple2', _0: 4, _1: 27},
			_1: {
				ctor: '::',
				_0: {ctor: '_Tuple2', _0: 6, _1: 25},
				_1: {
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: 8, _1: 46},
					_1: {ctor: '[]'}
				}
			}
		}
	}
};
var _terezka$elm_plot$PlotScatter$view = A2(
	_terezka$elm_plot$Plot$plot,
	{
		ctor: '::',
		_0: _terezka$elm_plot$Plot$size(_terezka$elm_plot$Common$plotSize),
		_1: {
			ctor: '::',
			_0: _terezka$elm_plot$Plot$margin(
				{ctor: '_Tuple4', _0: 10, _1: 20, _2: 40, _3: 40}),
			_1: {
				ctor: '::',
				_0: _terezka$elm_plot$Plot$domainLowest(
					_elm_lang$core$Basics$min(0)),
				_1: {ctor: '[]'}
			}
		}
	},
	{
		ctor: '::',
		_0: A2(
			_terezka$elm_plot$Plot$scatter,
			{
				ctor: '::',
				_0: _terezka$elm_plot$Plot_Scatter$stroke(_terezka$elm_plot$Common$pinkStroke),
				_1: {
					ctor: '::',
					_0: _terezka$elm_plot$Plot_Scatter$fill(_terezka$elm_plot$Common$pinkFill),
					_1: {
						ctor: '::',
						_0: _terezka$elm_plot$Plot_Scatter$radius(8),
						_1: {ctor: '[]'}
					}
				}
			},
			_terezka$elm_plot$PlotScatter$data),
		_1: {
			ctor: '::',
			_0: _terezka$elm_plot$Plot$xAxis(
				{
					ctor: '::',
					_0: _terezka$elm_plot$Plot_Axis$line(
						{
							ctor: '::',
							_0: _terezka$elm_plot$Plot_Line$stroke(_terezka$elm_plot$Common$axisColor),
							_1: {ctor: '[]'}
						}),
					_1: {
						ctor: '::',
						_0: _terezka$elm_plot$Plot_Axis$tickDelta(2),
						_1: {ctor: '[]'}
					}
				}),
			_1: {ctor: '[]'}
		}
	});
var _terezka$elm_plot$PlotScatter$id = 'PlotScatter';
var _terezka$elm_plot$PlotScatter$title = 'Scatters';
var _terezka$elm_plot$PlotScatter$plotExample = {
	title: _terezka$elm_plot$PlotScatter$title,
	code: _terezka$elm_plot$PlotScatter$code,
	view: _terezka$elm_plot$Common$ViewStatic(_terezka$elm_plot$PlotScatter$view),
	id: _terezka$elm_plot$PlotScatter$id
};

var _terezka$elm_plot$PlotGrid$code = '\n    view : Svg.Svg a\n    view =\n        plot\n            [ size plotSize\n            , margin ( 10, 20, 40, 20 )\n            ]\n            [ verticalGrid\n                [ Grid.lines\n                    [ Line.stroke axisColorLight ]\n                ]\n            , horizontalGrid\n                [ Grid.lines\n                    [ Line.stroke axisColorLight ]\n                , Grid.values [ 4, 8, 12 ]\n                ]\n            , xAxis\n                [ Axis.line [ Line.stroke axisColor ]\n                , Axis.tickDelta 0.5\n                ]\n            , line\n                [ Line.stroke blueStroke\n                , Line.strokeWidth 2\n                ]\n                data\n            ]\n    ';
var _terezka$elm_plot$PlotGrid$data = {
	ctor: '::',
	_0: {ctor: '_Tuple2', _0: 0, _1: 8},
	_1: {
		ctor: '::',
		_0: {ctor: '_Tuple2', _0: 1, _1: 0},
		_1: {
			ctor: '::',
			_0: {ctor: '_Tuple2', _0: 2, _1: 14},
			_1: {ctor: '[]'}
		}
	}
};
var _terezka$elm_plot$PlotGrid$view = A2(
	_terezka$elm_plot$Plot$plot,
	{
		ctor: '::',
		_0: _terezka$elm_plot$Plot$size(_terezka$elm_plot$Common$plotSize),
		_1: {
			ctor: '::',
			_0: _terezka$elm_plot$Plot$margin(
				{ctor: '_Tuple4', _0: 10, _1: 20, _2: 40, _3: 20}),
			_1: {ctor: '[]'}
		}
	},
	{
		ctor: '::',
		_0: _terezka$elm_plot$Plot$verticalGrid(
			{
				ctor: '::',
				_0: _terezka$elm_plot$Plot_Grid$lines(
					{
						ctor: '::',
						_0: _terezka$elm_plot$Plot_Line$stroke(_terezka$elm_plot$Common$axisColorLight),
						_1: {ctor: '[]'}
					}),
				_1: {ctor: '[]'}
			}),
		_1: {
			ctor: '::',
			_0: _terezka$elm_plot$Plot$horizontalGrid(
				{
					ctor: '::',
					_0: _terezka$elm_plot$Plot_Grid$lines(
						{
							ctor: '::',
							_0: _terezka$elm_plot$Plot_Line$stroke(_terezka$elm_plot$Common$axisColorLight),
							_1: {ctor: '[]'}
						}),
					_1: {
						ctor: '::',
						_0: _terezka$elm_plot$Plot_Grid$values(
							{
								ctor: '::',
								_0: 4,
								_1: {
									ctor: '::',
									_0: 8,
									_1: {
										ctor: '::',
										_0: 12,
										_1: {ctor: '[]'}
									}
								}
							}),
						_1: {ctor: '[]'}
					}
				}),
			_1: {
				ctor: '::',
				_0: _terezka$elm_plot$Plot$xAxis(
					{
						ctor: '::',
						_0: _terezka$elm_plot$Plot_Axis$line(
							{
								ctor: '::',
								_0: _terezka$elm_plot$Plot_Line$stroke(_terezka$elm_plot$Common$axisColor),
								_1: {ctor: '[]'}
							}),
						_1: {
							ctor: '::',
							_0: _terezka$elm_plot$Plot_Axis$tickDelta(0.5),
							_1: {ctor: '[]'}
						}
					}),
				_1: {
					ctor: '::',
					_0: A2(
						_terezka$elm_plot$Plot$line,
						{
							ctor: '::',
							_0: _terezka$elm_plot$Plot_Line$stroke(_terezka$elm_plot$Common$pinkStroke),
							_1: {
								ctor: '::',
								_0: _terezka$elm_plot$Plot_Line$strokeWidth(3),
								_1: {ctor: '[]'}
							}
						},
						_terezka$elm_plot$PlotGrid$data),
					_1: {ctor: '[]'}
				}
			}
		}
	});
var _terezka$elm_plot$PlotGrid$id = 'PlotGrid';
var _terezka$elm_plot$PlotGrid$title = 'Grids';
var _terezka$elm_plot$PlotGrid$plotExample = {
	title: _terezka$elm_plot$PlotGrid$title,
	code: _terezka$elm_plot$PlotGrid$code,
	view: _terezka$elm_plot$Common$ViewStatic(_terezka$elm_plot$PlotGrid$view),
	id: _terezka$elm_plot$PlotGrid$id
};

var _terezka$elm_plot$PlotTicks$code = '\n    isOdd : Int -> Bool\n    isOdd n =\n        rem n 2 > 0\n\n\n    toTickStyle : Axis.LabelInfo -> List (Tick.StyleAttribute msg)\n    toTickStyle { index } =\n        if isOdd index then\n            [ Tick.length 7\n            , Tick.stroke \"#e4e3e3\"\n            ]\n        else\n            [ Tick.length 10\n            , Tick.stroke \"#b9b9b9\"\n            ]\n\n\n    toLabelStyle : Axis.LabelInfo -> List (Label.StyleAttribute msg)\n    toLabelStyle { index } =\n        if isOdd index then\n            []\n        else\n            [ Label.stroke \"#969696\"\n            ]\n\n\n    view : Svg.Svg a\n    view =\n        plot\n            [ size plotSize\n            , margin ( 10, 20, 40, 20 )\n            ]\n            [ line\n                [ Line.stroke pinkStroke\n                , Line.strokeWidth 2\n                ]\n                data\n            , xAxis\n                [ Axis.line [ Line.stroke axisColor ]\n                , Axis.tick [ Tick.viewDynamic toTickStyle ]\n                , Axis.label\n                    [ Label.format\n                        (\\{ index, value } ->\n                            if isOdd index then\n                                \"\"\n                            else\n                                toString value ++ \" s\"\n                        )\n                    , Label.viewDynamic toLabelStyle\n                    ]\n                ]\n            ]\n    ';
var _terezka$elm_plot$PlotTicks$isOdd = function (n) {
	return _elm_lang$core$Native_Utils.cmp(
		A2(_elm_lang$core$Basics$rem, n, 2),
		0) > 0;
};
var _terezka$elm_plot$PlotTicks$toTickStyle = function (_p0) {
	var _p1 = _p0;
	return _terezka$elm_plot$PlotTicks$isOdd(_p1.index) ? {
		ctor: '::',
		_0: _terezka$elm_plot$Plot_Tick$length(7),
		_1: {
			ctor: '::',
			_0: _terezka$elm_plot$Plot_Tick$stroke('#e4e3e3'),
			_1: {ctor: '[]'}
		}
	} : {
		ctor: '::',
		_0: _terezka$elm_plot$Plot_Tick$length(10),
		_1: {
			ctor: '::',
			_0: _terezka$elm_plot$Plot_Tick$stroke('#b9b9b9'),
			_1: {ctor: '[]'}
		}
	};
};
var _terezka$elm_plot$PlotTicks$toLabelStyle = function (_p2) {
	var _p3 = _p2;
	return _terezka$elm_plot$PlotTicks$isOdd(_p3.index) ? {ctor: '[]'} : {
		ctor: '::',
		_0: _terezka$elm_plot$Plot_Label$stroke('#969696'),
		_1: {ctor: '[]'}
	};
};
var _terezka$elm_plot$PlotTicks$data = {
	ctor: '::',
	_0: {ctor: '_Tuple2', _0: 0, _1: 14},
	_1: {
		ctor: '::',
		_0: {ctor: '_Tuple2', _0: 1, _1: 16},
		_1: {
			ctor: '::',
			_0: {ctor: '_Tuple2', _0: 2, _1: 26},
			_1: {
				ctor: '::',
				_0: {ctor: '_Tuple2', _0: 3, _1: 32},
				_1: {
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: 4, _1: 28},
					_1: {
						ctor: '::',
						_0: {ctor: '_Tuple2', _0: 5, _1: 32},
						_1: {
							ctor: '::',
							_0: {ctor: '_Tuple2', _0: 6, _1: 29},
							_1: {
								ctor: '::',
								_0: {ctor: '_Tuple2', _0: 7, _1: 46},
								_1: {
									ctor: '::',
									_0: {ctor: '_Tuple2', _0: 8, _1: 52},
									_1: {
										ctor: '::',
										_0: {ctor: '_Tuple2', _0: 9, _1: 53},
										_1: {
											ctor: '::',
											_0: {ctor: '_Tuple2', _0: 10, _1: 59},
											_1: {ctor: '[]'}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
};
var _terezka$elm_plot$PlotTicks$view = A2(
	_terezka$elm_plot$Plot$plot,
	{
		ctor: '::',
		_0: _terezka$elm_plot$Plot$size(_terezka$elm_plot$Common$plotSize),
		_1: {
			ctor: '::',
			_0: _terezka$elm_plot$Plot$margin(
				{ctor: '_Tuple4', _0: 10, _1: 20, _2: 40, _3: 20}),
			_1: {ctor: '[]'}
		}
	},
	{
		ctor: '::',
		_0: A2(
			_terezka$elm_plot$Plot$line,
			{
				ctor: '::',
				_0: _terezka$elm_plot$Plot_Line$stroke(_terezka$elm_plot$Common$pinkStroke),
				_1: {
					ctor: '::',
					_0: _terezka$elm_plot$Plot_Line$strokeWidth(2),
					_1: {ctor: '[]'}
				}
			},
			_terezka$elm_plot$PlotTicks$data),
		_1: {
			ctor: '::',
			_0: _terezka$elm_plot$Plot$xAxis(
				{
					ctor: '::',
					_0: _terezka$elm_plot$Plot_Axis$line(
						{
							ctor: '::',
							_0: _terezka$elm_plot$Plot_Line$stroke(_terezka$elm_plot$Common$axisColor),
							_1: {ctor: '[]'}
						}),
					_1: {
						ctor: '::',
						_0: _terezka$elm_plot$Plot_Axis$tick(
							{
								ctor: '::',
								_0: _terezka$elm_plot$Plot_Tick$viewDynamic(_terezka$elm_plot$PlotTicks$toTickStyle),
								_1: {ctor: '[]'}
							}),
						_1: {
							ctor: '::',
							_0: _terezka$elm_plot$Plot_Axis$label(
								{
									ctor: '::',
									_0: _terezka$elm_plot$Plot_Label$format(
										function (_p4) {
											var _p5 = _p4;
											return _terezka$elm_plot$PlotTicks$isOdd(_p5.index) ? '' : A2(
												_elm_lang$core$Basics_ops['++'],
												_elm_lang$core$Basics$toString(_p5.value),
												' s');
										}),
									_1: {
										ctor: '::',
										_0: _terezka$elm_plot$Plot_Label$viewDynamic(_terezka$elm_plot$PlotTicks$toLabelStyle),
										_1: {ctor: '[]'}
									}
								}),
							_1: {ctor: '[]'}
						}
					}
				}),
			_1: {ctor: '[]'}
		}
	});
var _terezka$elm_plot$PlotTicks$id = 'PlotTicks';
var _terezka$elm_plot$PlotTicks$title = 'Custom ticks and labels';
var _terezka$elm_plot$PlotTicks$plotExample = {
	title: _terezka$elm_plot$PlotTicks$title,
	code: _terezka$elm_plot$PlotTicks$code,
	view: _terezka$elm_plot$Common$ViewStatic(_terezka$elm_plot$PlotTicks$view),
	id: _terezka$elm_plot$PlotTicks$id
};

var _terezka$elm_plot$PlotBars$code = '\n    view : Svg.Svg a\n    view =\n        plot\n            [ size Common.plotSize\n            , margin ( 10, 20, 40, 30 )\n            , padding ( 0, 20 )\n            ]\n            [ bars\n                [ Bars.maxBarWidth 30\n                , Bars.stackByY\n                , Bars.label\n                    [ Label.formatFromList [ \"A\", \"B\", \"C\" ]\n                    , Label.view\n                        [ Label.displace ( 0, 13 )\n                        , Label.fontSize 10\n                        ]\n                    ]\n                ]\n                [ [ Bars.fill Common.blueFill ]\n                , [ Bars.fill Common.skinFill ]\n                , [ Bars.fill Common.pinkFill ]\n                ]\n                (Bars.toBarData\n                    { yValues = .values\n                    , xValue = Nothing\n                    }\n                    [ { values = [ 1, 3, 2 ] }\n                    , { values = [ 2, 1, 4 ] }\n                    , { values = [ 4, 2, 1 ] }\n                    , { values = [ 4, 5, 2 ] }\n                    ]\n                )\n            , xAxis\n                [ Axis.line [ Line.stroke Common.axisColor ]\n                , Axis.tickDelta 1\n                ]\n            ]\n    ';
var _terezka$elm_plot$PlotBars$view = A2(
	_terezka$elm_plot$Plot$plot,
	{
		ctor: '::',
		_0: _terezka$elm_plot$Plot$size(_terezka$elm_plot$Common$plotSize),
		_1: {
			ctor: '::',
			_0: _terezka$elm_plot$Plot$margin(
				{ctor: '_Tuple4', _0: 10, _1: 20, _2: 40, _3: 30}),
			_1: {
				ctor: '::',
				_0: _terezka$elm_plot$Plot$padding(
					{ctor: '_Tuple2', _0: 0, _1: 20}),
				_1: {ctor: '[]'}
			}
		}
	},
	{
		ctor: '::',
		_0: A3(
			_terezka$elm_plot$Plot$bars,
			{
				ctor: '::',
				_0: _terezka$elm_plot$Plot_Bars$maxBarWidth(30),
				_1: {
					ctor: '::',
					_0: _terezka$elm_plot$Plot_Bars$stackByY,
					_1: {
						ctor: '::',
						_0: _terezka$elm_plot$Plot_Bars$label(
							{
								ctor: '::',
								_0: _terezka$elm_plot$Plot_Label$formatFromList(
									{
										ctor: '::',
										_0: 'A',
										_1: {
											ctor: '::',
											_0: 'B',
											_1: {
												ctor: '::',
												_0: 'C',
												_1: {ctor: '[]'}
											}
										}
									}),
								_1: {
									ctor: '::',
									_0: _terezka$elm_plot$Plot_Label$view(
										{
											ctor: '::',
											_0: _terezka$elm_plot$Plot_Label$displace(
												{ctor: '_Tuple2', _0: 0, _1: 13}),
											_1: {
												ctor: '::',
												_0: _terezka$elm_plot$Plot_Label$fontSize(10),
												_1: {ctor: '[]'}
											}
										}),
									_1: {ctor: '[]'}
								}
							}),
						_1: {ctor: '[]'}
					}
				}
			},
			{
				ctor: '::',
				_0: {
					ctor: '::',
					_0: _terezka$elm_plot$Plot_Bars$fill(_terezka$elm_plot$Common$blueFill),
					_1: {ctor: '[]'}
				},
				_1: {
					ctor: '::',
					_0: {
						ctor: '::',
						_0: _terezka$elm_plot$Plot_Bars$fill(_terezka$elm_plot$Common$skinFill),
						_1: {ctor: '[]'}
					},
					_1: {
						ctor: '::',
						_0: {
							ctor: '::',
							_0: _terezka$elm_plot$Plot_Bars$fill(_terezka$elm_plot$Common$pinkFill),
							_1: {ctor: '[]'}
						},
						_1: {ctor: '[]'}
					}
				}
			},
			A2(
				_terezka$elm_plot$Plot_Bars$toBarData,
				{
					yValues: function (_) {
						return _.values;
					},
					xValue: _elm_lang$core$Maybe$Nothing
				},
				{
					ctor: '::',
					_0: {
						values: {
							ctor: '::',
							_0: 40,
							_1: {
								ctor: '::',
								_0: 30,
								_1: {
									ctor: '::',
									_0: 20,
									_1: {ctor: '[]'}
								}
							}
						}
					},
					_1: {
						ctor: '::',
						_0: {
							values: {
								ctor: '::',
								_0: 20,
								_1: {
									ctor: '::',
									_0: 30,
									_1: {
										ctor: '::',
										_0: 40,
										_1: {ctor: '[]'}
									}
								}
							}
						},
						_1: {
							ctor: '::',
							_0: {
								values: {
									ctor: '::',
									_0: 40,
									_1: {
										ctor: '::',
										_0: 20,
										_1: {
											ctor: '::',
											_0: 10,
											_1: {ctor: '[]'}
										}
									}
								}
							},
							_1: {
								ctor: '::',
								_0: {
									values: {
										ctor: '::',
										_0: 40,
										_1: {
											ctor: '::',
											_0: 50,
											_1: {
												ctor: '::',
												_0: 20,
												_1: {ctor: '[]'}
											}
										}
									}
								},
								_1: {ctor: '[]'}
							}
						}
					}
				})),
		_1: {
			ctor: '::',
			_0: _terezka$elm_plot$Plot$xAxis(
				{
					ctor: '::',
					_0: _terezka$elm_plot$Plot_Axis$line(
						{
							ctor: '::',
							_0: _terezka$elm_plot$Plot_Line$stroke(_terezka$elm_plot$Common$axisColor),
							_1: {ctor: '[]'}
						}),
					_1: {
						ctor: '::',
						_0: _terezka$elm_plot$Plot_Axis$tickDelta(1),
						_1: {ctor: '[]'}
					}
				}),
			_1: {ctor: '[]'}
		}
	});
var _terezka$elm_plot$PlotBars$formatter = function (_p0) {
	var _p1 = _p0;
	return A2(
		_elm_lang$core$Basics_ops['++'],
		_elm_lang$core$Basics$toString(_p1.index),
		A2(
			_elm_lang$core$Basics_ops['++'],
			': (',
			A2(
				_elm_lang$core$Basics_ops['++'],
				_elm_lang$core$Basics$toString(_p1.xValue),
				A2(
					_elm_lang$core$Basics_ops['++'],
					', ',
					A2(
						_elm_lang$core$Basics_ops['++'],
						_elm_lang$core$Basics$toString(_p1.yValue),
						')')))));
};
var _terezka$elm_plot$PlotBars$id = 'PlotBars';
var _terezka$elm_plot$PlotBars$title = 'Bars';
var _terezka$elm_plot$PlotBars$plotExample = {
	title: _terezka$elm_plot$PlotBars$title,
	code: _terezka$elm_plot$PlotBars$code,
	view: _terezka$elm_plot$Common$ViewStatic(_terezka$elm_plot$PlotBars$view),
	id: _terezka$elm_plot$PlotBars$id
};

var _terezka$elm_plot$PlotSticky$code = '\n    isOdd : Int -> Bool\n    isOdd n =\n        rem n 2 > 0\n\n\n    toTickAttrs : List (Tick.StyleAttribute msg)\n    toTickAttrs =\n        [ Tick.length 7\n        , Tick.stroke \"#e4e3e3\"\n        ]\n\n\n    toLabelAttrsY : Axis.LabelInfo -> List (Label.StyleAttribute msg)\n    toLabelAttrsY { index, value } =\n        if not <| isOdd index then\n            []\n        else\n            [ Label.displace ( -5, 0 ) ]\n\n\n    view : Svg.Svg a\n    view =\n        plot\n            [ size plotSize\n            , margin ( 10, 20, 40, 20 )\n            , padding ( 0, 20 )\n            , domainLowest (always -21)\n            ]\n            [ line\n                [ Line.stroke pinkStroke\n                , Line.strokeWidth 2\n                ]\n                data\n            , xAxis\n                [ Axis.tick\n                    [ Tick.view toTickAttrs ]\n                , Axis.tickValues [ 3, 6 ]\n                , Axis.line [ Line.stroke axisColor ]\n                , Axis.label\n                    [ Label.format (\\{ value } -> toString value ++ \" ms\") ]\n                , Axis.cleanCrossings\n                ]\n            , yAxis\n                [ Axis.positionHighest\n                , Axis.line [ Line.stroke axisColor ]\n                , Axis.cleanCrossings\n                , Axis.tick [ Tick.view toTickAttrs ]\n                , Axis.label\n                    [ Label.viewDynamic toLabelAttrsY\n                    , Label.format\n                        (\\{ index, value } ->\n                            if not <| isOdd index then\n                                \"\"\n                            else\n                                toString (value * 10) ++ \" x\"\n                        )\n                    ]\n                ]\n            , yAxis\n                [ Axis.positionLowest\n                , Axis.cleanCrossings\n                , Axis.line [ Line.stroke axisColor ]\n                , Axis.anchorInside\n                , Axis.label\n                    [ Label.format\n                        (\\{ index, value } ->\n                            if isOdd index then\n                                \"\"\n                            else\n                                toString (value / 5) ++ \"k\"\n                        )\n                    ]\n                ]\n            ]\n    ';
var _terezka$elm_plot$PlotSticky$toTickAttrs = {
	ctor: '::',
	_0: _terezka$elm_plot$Plot_Tick$length(7),
	_1: {
		ctor: '::',
		_0: _terezka$elm_plot$Plot_Tick$stroke('#e4e3e3'),
		_1: {ctor: '[]'}
	}
};
var _terezka$elm_plot$PlotSticky$isOdd = function (n) {
	return _elm_lang$core$Native_Utils.cmp(
		A2(_elm_lang$core$Basics$rem, n, 2),
		0) > 0;
};
var _terezka$elm_plot$PlotSticky$toLabelAttrsY = function (_p0) {
	var _p1 = _p0;
	return (!_terezka$elm_plot$PlotSticky$isOdd(_p1.index)) ? {ctor: '[]'} : {
		ctor: '::',
		_0: _terezka$elm_plot$Plot_Label$displace(
			{ctor: '_Tuple2', _0: -5, _1: 0}),
		_1: {ctor: '[]'}
	};
};
var _terezka$elm_plot$PlotSticky$data = {
	ctor: '::',
	_0: {ctor: '_Tuple2', _0: 0, _1: 14},
	_1: {
		ctor: '::',
		_0: {ctor: '_Tuple2', _0: 1, _1: 16},
		_1: {
			ctor: '::',
			_0: {ctor: '_Tuple2', _0: 2, _1: 26},
			_1: {
				ctor: '::',
				_0: {ctor: '_Tuple2', _0: 3, _1: 32},
				_1: {
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: 4, _1: 28},
					_1: {
						ctor: '::',
						_0: {ctor: '_Tuple2', _0: 5, _1: 32},
						_1: {
							ctor: '::',
							_0: {ctor: '_Tuple2', _0: 6, _1: 29},
							_1: {
								ctor: '::',
								_0: {ctor: '_Tuple2', _0: 7, _1: 46},
								_1: {
									ctor: '::',
									_0: {ctor: '_Tuple2', _0: 8, _1: 52},
									_1: {
										ctor: '::',
										_0: {ctor: '_Tuple2', _0: 9, _1: 53},
										_1: {
											ctor: '::',
											_0: {ctor: '_Tuple2', _0: 10, _1: 59},
											_1: {ctor: '[]'}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
};
var _terezka$elm_plot$PlotSticky$view = A2(
	_terezka$elm_plot$Plot$plot,
	{
		ctor: '::',
		_0: _terezka$elm_plot$Plot$size(_terezka$elm_plot$Common$plotSize),
		_1: {
			ctor: '::',
			_0: _terezka$elm_plot$Plot$margin(
				{ctor: '_Tuple4', _0: 10, _1: 20, _2: 40, _3: 20}),
			_1: {
				ctor: '::',
				_0: _terezka$elm_plot$Plot$padding(
					{ctor: '_Tuple2', _0: 0, _1: 20}),
				_1: {
					ctor: '::',
					_0: _terezka$elm_plot$Plot$domainLowest(
						_elm_lang$core$Basics$always(-21)),
					_1: {ctor: '[]'}
				}
			}
		}
	},
	{
		ctor: '::',
		_0: A2(
			_terezka$elm_plot$Plot$line,
			{
				ctor: '::',
				_0: _terezka$elm_plot$Plot_Line$stroke(_terezka$elm_plot$Common$pinkStroke),
				_1: {
					ctor: '::',
					_0: _terezka$elm_plot$Plot_Line$strokeWidth(2),
					_1: {ctor: '[]'}
				}
			},
			_terezka$elm_plot$PlotSticky$data),
		_1: {
			ctor: '::',
			_0: _terezka$elm_plot$Plot$xAxis(
				{
					ctor: '::',
					_0: _terezka$elm_plot$Plot_Axis$tick(
						{
							ctor: '::',
							_0: _terezka$elm_plot$Plot_Tick$view(_terezka$elm_plot$PlotSticky$toTickAttrs),
							_1: {ctor: '[]'}
						}),
					_1: {
						ctor: '::',
						_0: _terezka$elm_plot$Plot_Axis$tickValues(
							{
								ctor: '::',
								_0: 3,
								_1: {
									ctor: '::',
									_0: 6,
									_1: {ctor: '[]'}
								}
							}),
						_1: {
							ctor: '::',
							_0: _terezka$elm_plot$Plot_Axis$line(
								{
									ctor: '::',
									_0: _terezka$elm_plot$Plot_Line$stroke(_terezka$elm_plot$Common$axisColor),
									_1: {ctor: '[]'}
								}),
							_1: {
								ctor: '::',
								_0: _terezka$elm_plot$Plot_Axis$label(
									{
										ctor: '::',
										_0: _terezka$elm_plot$Plot_Label$format(
											function (_p2) {
												var _p3 = _p2;
												return A2(
													_elm_lang$core$Basics_ops['++'],
													_elm_lang$core$Basics$toString(_p3.value),
													' ms');
											}),
										_1: {ctor: '[]'}
									}),
								_1: {
									ctor: '::',
									_0: _terezka$elm_plot$Plot_Axis$cleanCrossings,
									_1: {ctor: '[]'}
								}
							}
						}
					}
				}),
			_1: {
				ctor: '::',
				_0: _terezka$elm_plot$Plot$yAxis(
					{
						ctor: '::',
						_0: _terezka$elm_plot$Plot_Axis$positionHighest,
						_1: {
							ctor: '::',
							_0: _terezka$elm_plot$Plot_Axis$cleanCrossings,
							_1: {
								ctor: '::',
								_0: _terezka$elm_plot$Plot_Axis$tick(
									{
										ctor: '::',
										_0: _terezka$elm_plot$Plot_Tick$view(_terezka$elm_plot$PlotSticky$toTickAttrs),
										_1: {ctor: '[]'}
									}),
								_1: {
									ctor: '::',
									_0: _terezka$elm_plot$Plot_Axis$line(
										{
											ctor: '::',
											_0: _terezka$elm_plot$Plot_Line$stroke(_terezka$elm_plot$Common$axisColor),
											_1: {ctor: '[]'}
										}),
									_1: {
										ctor: '::',
										_0: _terezka$elm_plot$Plot_Axis$label(
											{
												ctor: '::',
												_0: _terezka$elm_plot$Plot_Label$viewDynamic(_terezka$elm_plot$PlotSticky$toLabelAttrsY),
												_1: {
													ctor: '::',
													_0: _terezka$elm_plot$Plot_Label$format(
														function (_p4) {
															var _p5 = _p4;
															return (!_terezka$elm_plot$PlotSticky$isOdd(_p5.index)) ? '' : A2(
																_elm_lang$core$Basics_ops['++'],
																_elm_lang$core$Basics$toString(_p5.value * 10),
																' x');
														}),
													_1: {ctor: '[]'}
												}
											}),
										_1: {ctor: '[]'}
									}
								}
							}
						}
					}),
				_1: {
					ctor: '::',
					_0: _terezka$elm_plot$Plot$yAxis(
						{
							ctor: '::',
							_0: _terezka$elm_plot$Plot_Axis$positionLowest,
							_1: {
								ctor: '::',
								_0: _terezka$elm_plot$Plot_Axis$cleanCrossings,
								_1: {
									ctor: '::',
									_0: _terezka$elm_plot$Plot_Axis$anchorInside,
									_1: {
										ctor: '::',
										_0: _terezka$elm_plot$Plot_Axis$line(
											{
												ctor: '::',
												_0: _terezka$elm_plot$Plot_Line$stroke(_terezka$elm_plot$Common$axisColor),
												_1: {ctor: '[]'}
											}),
										_1: {
											ctor: '::',
											_0: _terezka$elm_plot$Plot_Axis$label(
												{
													ctor: '::',
													_0: _terezka$elm_plot$Plot_Label$format(
														function (_p6) {
															var _p7 = _p6;
															return _terezka$elm_plot$PlotSticky$isOdd(_p7.index) ? '' : A2(
																_elm_lang$core$Basics_ops['++'],
																_elm_lang$core$Basics$toString(_p7.value / 5),
																'k');
														}),
													_1: {ctor: '[]'}
												}),
											_1: {ctor: '[]'}
										}
									}
								}
							}
						}),
					_1: {ctor: '[]'}
				}
			}
		}
	});
var _terezka$elm_plot$PlotSticky$id = 'PlotSticky';
var _terezka$elm_plot$PlotSticky$title = 'Sticky axis';
var _terezka$elm_plot$PlotSticky$plotExample = {
	title: _terezka$elm_plot$PlotSticky$title,
	code: _terezka$elm_plot$PlotSticky$code,
	view: _terezka$elm_plot$Common$ViewStatic(_terezka$elm_plot$PlotSticky$view),
	id: _terezka$elm_plot$PlotSticky$id
};

var _terezka$elm_plot$PlotHint$code = '\n    view : State -> Svg.Svg (Interaction msg)\n    view state =\n        plotInteractive\n            [ size plotSize\n            , margin ( 10, 20, 40, 40 )\n            ]\n            [ bars\n                [ Bars.maxBarWidthPer 85 ]\n                [ [ Bars.fill Common.blueFill ]\n                , [ Bars.fill Common.skinFill ]\n                , [ Bars.fill Common.pinkFill ]\n                ]\n                (Bars.toBarData\n                    { yValues = .values\n                    , xValue = Nothing\n                    }\n                    [ { values = [ 1, 3, 2 ] }\n                    , { values = [ 2, 1, 4 ] }\n                    , { values = [ 4, 2, 1 ] }\n                    , { values = [ 4, 5, 2 ] }\n                    ]\n                )\n            , xAxis\n                [ Axis.line [ Line.stroke axisColor ]\n                , Axis.tickDelta 1\n                ]\n            , hint\n                [ Hint.lineStyle [ ( \"background\", \"#b9b9b9\" ) ] ]\n                (getHoveredValue state)\n            ]\n    ';
var _terezka$elm_plot$PlotHint$view = function (state) {
	return A2(
		_terezka$elm_plot$Plot$plotInteractive,
		{
			ctor: '::',
			_0: _terezka$elm_plot$Plot$size(_terezka$elm_plot$Common$plotSize),
			_1: {
				ctor: '::',
				_0: _terezka$elm_plot$Plot$margin(
					{ctor: '_Tuple4', _0: 10, _1: 20, _2: 40, _3: 40}),
				_1: {ctor: '[]'}
			}
		},
		{
			ctor: '::',
			_0: A3(
				_terezka$elm_plot$Plot$bars,
				{
					ctor: '::',
					_0: _terezka$elm_plot$Plot_Bars$maxBarWidthPer(85),
					_1: {ctor: '[]'}
				},
				{
					ctor: '::',
					_0: {
						ctor: '::',
						_0: _terezka$elm_plot$Plot_Bars$fill(_terezka$elm_plot$Common$blueFill),
						_1: {ctor: '[]'}
					},
					_1: {
						ctor: '::',
						_0: {
							ctor: '::',
							_0: _terezka$elm_plot$Plot_Bars$fill(_terezka$elm_plot$Common$skinFill),
							_1: {ctor: '[]'}
						},
						_1: {
							ctor: '::',
							_0: {
								ctor: '::',
								_0: _terezka$elm_plot$Plot_Bars$fill(_terezka$elm_plot$Common$pinkFill),
								_1: {ctor: '[]'}
							},
							_1: {ctor: '[]'}
						}
					}
				},
				A2(
					_terezka$elm_plot$Plot_Bars$toBarData,
					{
						yValues: function (_) {
							return _.values;
						},
						xValue: _elm_lang$core$Maybe$Nothing
					},
					{
						ctor: '::',
						_0: {
							values: {
								ctor: '::',
								_0: 1,
								_1: {
									ctor: '::',
									_0: 3,
									_1: {
										ctor: '::',
										_0: 2,
										_1: {ctor: '[]'}
									}
								}
							}
						},
						_1: {
							ctor: '::',
							_0: {
								values: {
									ctor: '::',
									_0: 2,
									_1: {
										ctor: '::',
										_0: 1,
										_1: {
											ctor: '::',
											_0: 4,
											_1: {ctor: '[]'}
										}
									}
								}
							},
							_1: {
								ctor: '::',
								_0: {
									values: {
										ctor: '::',
										_0: 4,
										_1: {
											ctor: '::',
											_0: 2,
											_1: {
												ctor: '::',
												_0: 1,
												_1: {ctor: '[]'}
											}
										}
									}
								},
								_1: {
									ctor: '::',
									_0: {
										values: {
											ctor: '::',
											_0: 4,
											_1: {
												ctor: '::',
												_0: 5,
												_1: {
													ctor: '::',
													_0: 2,
													_1: {ctor: '[]'}
												}
											}
										}
									},
									_1: {ctor: '[]'}
								}
							}
						}
					})),
			_1: {
				ctor: '::',
				_0: _terezka$elm_plot$Plot$xAxis(
					{
						ctor: '::',
						_0: _terezka$elm_plot$Plot_Axis$line(
							{
								ctor: '::',
								_0: _terezka$elm_plot$Plot_Line$stroke(_terezka$elm_plot$Common$axisColor),
								_1: {ctor: '[]'}
							}),
						_1: {
							ctor: '::',
							_0: _terezka$elm_plot$Plot_Axis$tickDelta(1),
							_1: {ctor: '[]'}
						}
					}),
				_1: {
					ctor: '::',
					_0: A2(
						_terezka$elm_plot$Plot$hint,
						{
							ctor: '::',
							_0: _terezka$elm_plot$Plot_Hint$lineStyle(
								{
									ctor: '::',
									_0: {ctor: '_Tuple2', _0: 'background', _1: '#b9b9b9'},
									_1: {ctor: '[]'}
								}),
							_1: {ctor: '[]'}
						},
						_terezka$elm_plot$Plot$getHoveredValue(state)),
					_1: {ctor: '[]'}
				}
			}
		});
};
var _terezka$elm_plot$PlotHint$data2 = {
	ctor: '::',
	_0: {ctor: '_Tuple2', _0: 0, _1: 0},
	_1: {
		ctor: '::',
		_0: {ctor: '_Tuple2', _0: 1, _1: 5},
		_1: {
			ctor: '::',
			_0: {ctor: '_Tuple2', _0: 2, _1: 7},
			_1: {
				ctor: '::',
				_0: {ctor: '_Tuple2', _0: 3, _1: 15},
				_1: {ctor: '[]'}
			}
		}
	}
};
var _terezka$elm_plot$PlotHint$data1 = {
	ctor: '::',
	_0: {ctor: '_Tuple2', _0: 0, _1: 2},
	_1: {
		ctor: '::',
		_0: {ctor: '_Tuple2', _0: 1, _1: 4},
		_1: {
			ctor: '::',
			_0: {ctor: '_Tuple2', _0: 2, _1: 5},
			_1: {
				ctor: '::',
				_0: {ctor: '_Tuple2', _0: 3, _1: 10},
				_1: {ctor: '[]'}
			}
		}
	}
};
var _terezka$elm_plot$PlotHint$id = 'PlotHint';
var _terezka$elm_plot$PlotHint$title = 'Hints';
var _terezka$elm_plot$PlotHint$plotExample = {
	title: _terezka$elm_plot$PlotHint$title,
	code: _terezka$elm_plot$PlotHint$code,
	id: _terezka$elm_plot$PlotHint$id,
	view: A2(_terezka$elm_plot$Common$ViewInteractive, _terezka$elm_plot$PlotHint$id, _terezka$elm_plot$PlotHint$view)
};

var _terezka$elm_plot$PlotSmooth$code = '\n    view : Svg.Svg a\n    view =\n        plot\n            [ size plotSize\n            , margin ( 10, 20, 40, 20 )\n            ]\n            [ area\n                [ Area.stroke pinkStroke\n                , Area.fill pinkFill\n                , Area.strokeWidth 1\n                , Area.smoothingBezier\n                ]\n                data1\n            , xAxis\n                [ Axis.line [ Line.stroke axisColor ]\n                , Axis.tickDelta 1\n                ]\n            ]\n    ';
var _terezka$elm_plot$PlotSmooth$data1 = {
	ctor: '::',
	_0: {ctor: '_Tuple2', _0: 0, _1: 10},
	_1: {
		ctor: '::',
		_0: {ctor: '_Tuple2', _0: 0.5, _1: 20},
		_1: {
			ctor: '::',
			_0: {ctor: '_Tuple2', _0: 1, _1: 5},
			_1: {
				ctor: '::',
				_0: {ctor: '_Tuple2', _0: 1.5, _1: 4},
				_1: {
					ctor: '::',
					_0: {ctor: '_Tuple2', _0: 2, _1: 7},
					_1: {
						ctor: '::',
						_0: {ctor: '_Tuple2', _0: 2.5, _1: 5},
						_1: {
							ctor: '::',
							_0: {ctor: '_Tuple2', _0: 3, _1: 10},
							_1: {
								ctor: '::',
								_0: {ctor: '_Tuple2', _0: 3.5, _1: 15},
								_1: {ctor: '[]'}
							}
						}
					}
				}
			}
		}
	}
};
var _terezka$elm_plot$PlotSmooth$view = A2(
	_terezka$elm_plot$Plot$plot,
	{
		ctor: '::',
		_0: _terezka$elm_plot$Plot$size(_terezka$elm_plot$Common$plotSize),
		_1: {
			ctor: '::',
			_0: _terezka$elm_plot$Plot$margin(
				{ctor: '_Tuple4', _0: 10, _1: 20, _2: 40, _3: 20}),
			_1: {ctor: '[]'}
		}
	},
	{
		ctor: '::',
		_0: A2(
			_terezka$elm_plot$Plot$area,
			{
				ctor: '::',
				_0: _terezka$elm_plot$Plot_Area$stroke(_terezka$elm_plot$Common$pinkStroke),
				_1: {
					ctor: '::',
					_0: _terezka$elm_plot$Plot_Area$fill(_terezka$elm_plot$Common$pinkFill),
					_1: {
						ctor: '::',
						_0: _terezka$elm_plot$Plot_Area$strokeWidth(1),
						_1: {
							ctor: '::',
							_0: _terezka$elm_plot$Plot_Area$smoothingBezier,
							_1: {ctor: '[]'}
						}
					}
				}
			},
			_terezka$elm_plot$PlotSmooth$data1),
		_1: {
			ctor: '::',
			_0: _terezka$elm_plot$Plot$xAxis(
				{
					ctor: '::',
					_0: _terezka$elm_plot$Plot_Axis$line(
						{
							ctor: '::',
							_0: _terezka$elm_plot$Plot_Line$stroke(_terezka$elm_plot$Common$axisColor),
							_1: {ctor: '[]'}
						}),
					_1: {
						ctor: '::',
						_0: _terezka$elm_plot$Plot_Axis$tickDelta(1),
						_1: {ctor: '[]'}
					}
				}),
			_1: {ctor: '[]'}
		}
	});
var _terezka$elm_plot$PlotSmooth$id = 'PlotSmooth';
var _terezka$elm_plot$PlotSmooth$title = 'Interpolation';
var _terezka$elm_plot$PlotSmooth$plotExample = {
	title: _terezka$elm_plot$PlotSmooth$title,
	code: _terezka$elm_plot$PlotSmooth$code,
	view: _terezka$elm_plot$Common$ViewStatic(_terezka$elm_plot$PlotSmooth$view),
	id: _terezka$elm_plot$PlotSmooth$id
};

var _terezka$elm_plot$Docs$examples = {
	ctor: '::',
	_0: _terezka$elm_plot$PlotSmooth$plotExample,
	_1: {
		ctor: '::',
		_0: _terezka$elm_plot$PlotBars$plotExample,
		_1: {
			ctor: '::',
			_0: _terezka$elm_plot$PlotHint$plotExample,
			_1: {
				ctor: '::',
				_0: _terezka$elm_plot$PlotSticky$plotExample,
				_1: {
					ctor: '::',
					_0: _terezka$elm_plot$PlotScatter$plotExample,
					_1: {
						ctor: '::',
						_0: _terezka$elm_plot$PlotTicks$plotExample,
						_1: {
							ctor: '::',
							_0: _terezka$elm_plot$PlotGrid$plotExample,
							_1: {ctor: '[]'}
						}
					}
				}
			}
		}
	}
};
var _terezka$elm_plot$Docs$getVisibility = F2(
	function (_p0, id) {
		var _p1 = _p0;
		return _elm_lang$core$Native_Utils.eq(
			_p1.focused,
			_elm_lang$core$Maybe$Just(id)) ? {
			ctor: '::',
			_0: {ctor: '_Tuple2', _0: 'display', _1: 'block'},
			_1: {ctor: '[]'}
		} : {
			ctor: '::',
			_0: {ctor: '_Tuple2', _0: 'display', _1: 'none'},
			_1: {ctor: '[]'}
		};
	});
var _terezka$elm_plot$Docs$toUrl = function (end) {
	return A2(
		_elm_lang$core$Basics_ops['++'],
		'https://github.com/terezka/elm-plot/blob/master/docs/',
		A2(_elm_lang$core$Basics_ops['++'], end, '.elm'));
};
var _terezka$elm_plot$Docs$viewFooter = A2(
	_elm_lang$html$Html$div,
	{
		ctor: '::',
		_0: _elm_lang$html$Html_Attributes$class('view__footer'),
		_1: {ctor: '[]'}
	},
	{
		ctor: '::',
		_0: _elm_lang$html$Html$text('Made by '),
		_1: {
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$a,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$href('https://twitter.com/terexka'),
					_1: {
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$style(
							{
								ctor: '::',
								_0: {ctor: '_Tuple2', _0: 'color', _1: '#84868a'},
								_1: {ctor: '[]'}
							}),
						_1: {ctor: '[]'}
					}
				},
				{
					ctor: '::',
					_0: _elm_lang$html$Html$text('@terexka'),
					_1: {ctor: '[]'}
				}),
			_1: {ctor: '[]'}
		}
	});
var _terezka$elm_plot$Docs$viewLink = function (id) {
	return A2(
		_elm_lang$html$Html$a,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('view-code__link'),
			_1: {
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$href(
					_terezka$elm_plot$Docs$toUrl(id)),
				_1: {ctor: '[]'}
			}
		},
		{
			ctor: '::',
			_0: _elm_lang$html$Html$text('See full source'),
			_1: {ctor: '[]'}
		});
};
var _terezka$elm_plot$Docs$viewCode = F2(
	function (model, _p2) {
		var _p3 = _p2;
		var _p4 = _p3.id;
		return A2(
			_elm_lang$html$Html$div,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$style(
					A2(_terezka$elm_plot$Docs$getVisibility, model, _p4)),
				_1: {
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('view-code'),
					_1: {ctor: '[]'}
				}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$code,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('elm view-code__inner'),
						_1: {ctor: '[]'}
					},
					{
						ctor: '::',
						_0: A2(
							_elm_lang$html$Html$pre,
							{ctor: '[]'},
							{
								ctor: '::',
								_0: _elm_lang$html$Html$text(_p3.code),
								_1: {ctor: '[]'}
							}),
						_1: {ctor: '[]'}
					}),
				_1: {
					ctor: '::',
					_0: _terezka$elm_plot$Docs$viewLink(_p4),
					_1: {ctor: '[]'}
				}
			});
	});
var _terezka$elm_plot$Docs$viewTitle = A2(
	_elm_lang$html$Html$div,
	{ctor: '[]'},
	{
		ctor: '::',
		_0: A2(
			_elm_lang$html$Html$img,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$src('logo.png'),
				_1: {
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('view__logo'),
					_1: {ctor: '[]'}
				}
			},
			{ctor: '[]'}),
		_1: {
			ctor: '::',
			_0: A2(
				_elm_lang$html$Html$h1,
				{
					ctor: '::',
					_0: _elm_lang$html$Html_Attributes$class('view__title'),
					_1: {ctor: '[]'}
				},
				{
					ctor: '::',
					_0: _elm_lang$html$Html$text('Elm Plot'),
					_1: {ctor: '[]'}
				}),
			_1: {
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$div,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$class('view__github-link'),
						_1: {ctor: '[]'}
					},
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text('Find it on '),
						_1: {
							ctor: '::',
							_0: A2(
								_elm_lang$html$Html$a,
								{
									ctor: '::',
									_0: _elm_lang$html$Html_Attributes$href('https://github.com/terezka/elm-plot'),
									_1: {ctor: '[]'}
								},
								{
									ctor: '::',
									_0: _elm_lang$html$Html$text('Github'),
									_1: {ctor: '[]'}
								}),
							_1: {ctor: '[]'}
						}
					}),
				_1: {ctor: '[]'}
			}
		}
	});
var _terezka$elm_plot$Docs$setPlotState = F3(
	function (id, newState, states) {
		return A3(
			_elm_lang$core$Dict$update,
			id,
			_elm_lang$core$Basics$always(
				_elm_lang$core$Maybe$Just(newState)),
			states);
	});
var _terezka$elm_plot$Docs$updateFocused = F2(
	function (newId, model) {
		var _p5 = model;
		if (_p5.ctor === 'Nothing') {
			return _elm_lang$core$Maybe$Just(newId);
		} else {
			return _elm_lang$core$Native_Utils.eq(_p5._0, newId) ? _elm_lang$core$Maybe$Nothing : _elm_lang$core$Maybe$Just(newId);
		}
	});
var _terezka$elm_plot$Docs$getPlotState = F2(
	function (id, plotStates) {
		return A2(
			_elm_lang$core$Maybe$withDefault,
			_terezka$elm_plot$Plot$initialState,
			A2(_elm_lang$core$Dict$get, id, plotStates));
	});
var _terezka$elm_plot$Docs$update = F2(
	function (msg, _p6) {
		update:
		while (true) {
			var _p7 = _p6;
			var _p12 = _p7.plotStates;
			var _p11 = _p7;
			var _p8 = msg;
			if (_p8.ctor === 'FocusExample') {
				return {
					ctor: '_Tuple2',
					_0: _elm_lang$core$Native_Utils.update(
						_p11,
						{
							focused: A2(_terezka$elm_plot$Docs$updateFocused, _p8._0, _p7.focused)
						}),
					_1: _elm_lang$core$Platform_Cmd$none
				};
			} else {
				var _p10 = _p8._0;
				var _p9 = _p8._1;
				if (_p9.ctor === 'Internal') {
					var plotState = A2(_terezka$elm_plot$Docs$getPlotState, _p10, _p12);
					var newState = A2(_terezka$elm_plot$Plot$update, _p9._0, plotState);
					return {
						ctor: '_Tuple2',
						_0: _elm_lang$core$Native_Utils.update(
							_p11,
							{
								plotStates: A3(_terezka$elm_plot$Docs$setPlotState, _p10, newState, _p12)
							}),
						_1: _elm_lang$core$Platform_Cmd$none
					};
				} else {
					var _v6 = _p9._0,
						_v7 = _p11;
					msg = _v6;
					_p6 = _v7;
					continue update;
				}
			}
		}
	});
var _terezka$elm_plot$Docs$initialModel = {focused: _elm_lang$core$Maybe$Nothing, plotStates: _elm_lang$core$Dict$empty};
var _terezka$elm_plot$Docs$highlight = _elm_lang$core$Native_Platform.outgoingPort(
	'highlight',
	function (v) {
		return null;
	});
var _terezka$elm_plot$Docs$Model = F2(
	function (a, b) {
		return {focused: a, plotStates: b};
	});
var _terezka$elm_plot$Docs$PlotInteraction = F2(
	function (a, b) {
		return {ctor: 'PlotInteraction', _0: a, _1: b};
	});
var _terezka$elm_plot$Docs$viewExampleLarge = function (_p13) {
	var _p14 = _p13;
	return A2(
		_elm_lang$html$Html$map,
		_terezka$elm_plot$Docs$PlotInteraction(_terezka$elm_plot$PlotComposed$id),
		_terezka$elm_plot$PlotComposed$view(
			A2(_terezka$elm_plot$Docs$getPlotState, _terezka$elm_plot$PlotComposed$id, _p14.plotStates)));
};
var _terezka$elm_plot$Docs$viewExampleInner = F2(
	function (_p15, view) {
		var _p16 = _p15;
		var _p17 = view;
		if (_p17.ctor === 'ViewInteractive') {
			var _p18 = _p17._0;
			return A2(
				_elm_lang$html$Html$map,
				_terezka$elm_plot$Docs$PlotInteraction(_p18),
				_p17._1(
					A2(_terezka$elm_plot$Docs$getPlotState, _p18, _p16.plotStates)));
		} else {
			return _p17._0;
		}
	});
var _terezka$elm_plot$Docs$FocusExample = function (a) {
	return {ctor: 'FocusExample', _0: a};
};
var _terezka$elm_plot$Docs$viewToggler = function (id) {
	return A2(
		_elm_lang$html$Html$p,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('view-heading__code-open'),
			_1: {
				ctor: '::',
				_0: _elm_lang$html$Html_Events$onClick(
					_terezka$elm_plot$Docs$FocusExample(id)),
				_1: {ctor: '[]'}
			}
		},
		{
			ctor: '::',
			_0: _elm_lang$html$Html$text('View source snippet'),
			_1: {ctor: '[]'}
		});
};
var _terezka$elm_plot$Docs$viewHeading = F2(
	function (model, _p19) {
		var _p20 = _p19;
		var _p21 = _p20.id;
		return A2(
			_elm_lang$html$Html$div,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('view-heading'),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A2(
					_elm_lang$html$Html$a,
					{
						ctor: '::',
						_0: _elm_lang$html$Html_Attributes$name(_p21),
						_1: {
							ctor: '::',
							_0: _elm_lang$html$Html_Attributes$href(
								A2(_elm_lang$core$Basics_ops['++'], '#', _p21)),
							_1: {ctor: '[]'}
						}
					},
					{
						ctor: '::',
						_0: _elm_lang$html$Html$text(_p20.title),
						_1: {ctor: '[]'}
					}),
				_1: {
					ctor: '::',
					_0: _terezka$elm_plot$Docs$viewToggler(_p21),
					_1: {ctor: '[]'}
				}
			});
	});
var _terezka$elm_plot$Docs$viewExample = F2(
	function (_p23, _p22) {
		var _p24 = _p23;
		var _p27 = _p24;
		var _p25 = _p22;
		var _p26 = _p25;
		return A2(
			_elm_lang$html$Html$div,
			{
				ctor: '::',
				_0: _elm_lang$html$Html_Attributes$class('view-plot'),
				_1: {ctor: '[]'}
			},
			{
				ctor: '::',
				_0: A2(_terezka$elm_plot$Docs$viewHeading, _p27, _p26),
				_1: {
					ctor: '::',
					_0: A2(_terezka$elm_plot$Docs$viewCode, _p27, _p26),
					_1: {
						ctor: '::',
						_0: A2(_terezka$elm_plot$Docs$viewExampleInner, _p27, _p25.view),
						_1: {ctor: '[]'}
					}
				}
			});
	});
var _terezka$elm_plot$Docs$view = function (model) {
	return A2(
		_elm_lang$html$Html$div,
		{
			ctor: '::',
			_0: _elm_lang$html$Html_Attributes$class('view'),
			_1: {ctor: '[]'}
		},
		{
			ctor: '::',
			_0: _terezka$elm_plot$Docs$viewTitle,
			_1: {
				ctor: '::',
				_0: _terezka$elm_plot$Docs$viewExampleLarge(model),
				_1: {
					ctor: '::',
					_0: A2(
						_elm_lang$html$Html$div,
						{ctor: '[]'},
						A2(
							_elm_lang$core$List$map,
							_terezka$elm_plot$Docs$viewExample(model),
							_terezka$elm_plot$Docs$examples)),
					_1: {
						ctor: '::',
						_0: _terezka$elm_plot$Docs$viewFooter,
						_1: {ctor: '[]'}
					}
				}
			}
		});
};
var _terezka$elm_plot$Docs$main = _elm_lang$html$Html$program(
	{
		init: {
			ctor: '_Tuple2',
			_0: _terezka$elm_plot$Docs$initialModel,
			_1: _terezka$elm_plot$Docs$highlight(
				{ctor: '_Tuple0'})
		},
		update: _terezka$elm_plot$Docs$update,
		subscriptions: _elm_lang$core$Basics$always(_elm_lang$core$Platform_Sub$none),
		view: _terezka$elm_plot$Docs$view
	})();

var Elm = {};
Elm['Docs'] = Elm['Docs'] || {};
if (typeof _terezka$elm_plot$Docs$main !== 'undefined') {
    _terezka$elm_plot$Docs$main(Elm['Docs'], 'Docs', undefined);
}

if (typeof define === "function" && define['amd'])
{
  define([], function() { return Elm; });
  return;
}

if (typeof module === "object")
{
  module['exports'] = Elm;
  return;
}

var globalElm = this['Elm'];
if (typeof globalElm === "undefined")
{
  this['Elm'] = Elm;
  return;
}

for (var publicModule in Elm)
{
  if (publicModule in globalElm)
  {
    throw new Error('There are two Elm modules called `' + publicModule + '` on this page! Rename one of them.');
  }
  globalElm[publicModule] = Elm[publicModule];
}

}).call(this);

