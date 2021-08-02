# How Android Layout Inflater Works?


### How LayoutInflate is usually called
public class SomeFragment extends Fragment {
  public View onCreateView(LayoutInflater inflater, ViewGroup root, Bundle savedInstanceState) {
    return inflater.inflate(R.layout.some_fragment, root, false);
  }
}

### or
### (Note: this is activity context (not application context))
val inflater = LayoutInflater.from(context)


### Step 1
### Android Asset Packaging Tool (aapt)
### this happens at build time
regular xml -> binary xml

### Step 3
### LayoutInflater.inflate() -> Java objects in heap
### this happens at runtime

### Step 3
### Java objects in heap -> onMeasure(), onLayout(), onDraw()


### inflate() implementation:
View inflate(int resource, ViewGroup root, boolean attachToRoot) {
    XmlResourceParser parser = resources.getLayout(resource);
    return inflate(parser, root, attachToRoot);
}

### Why do we need root?
### root is used to determine the specific type of ViewGroup.LayoutParams
params = root.generateLayoutParams(attrs);


### Why do we need attachToRoot?
if (attachToRoot) {
  root.addView(inflatedViewTree, params);
}

### What does inflate() return?
- if attachToRoot == true, then returns the root view
- otherwise returns the inflated view


### So how does inflate work?
- It recursively creates View + its LayoutParams
- It adds the child view and its LayoutParams to the parent root
- It repeats recursively until the entire inflated view tree is built

