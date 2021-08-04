# How Android measures, layouts and draws views?

## Basic stages
### (Note: Measure, layout, draw are Depth-First-Traversals)
### What basically happens is the parent and the child negotiate the child size
- Inflation/instantiation -> view hierarchy
- Measure
- Layout
- Draw



## View life cycle 
CustomView constructor -> onAttachedToWindow() -> 
    (return here after requestLayout() call)
-> measure() -> onMeasure() -> 
-> layout() -> onLayout() -> 
    (return here after invalidate() call)
-> dispatchDraw() -> draw() -> onDraw()




## View Constructor
### Called during inflation from xml and instantiation from java code
### when created from code:
- CustomView (Context context)
### when created from xml:
- CustomView (Context context, AttributeSet attrs)
- CustomView (Context context, AttributeSet attrs, int defStyleAttr)
- CustomView (Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes)




## parent.addView(child, layoutParams)
### child.onAttachedToWindow()
### The child becomes a part in the parent's view hierarchy
- child defines LayoutParams (via Java or xml)
- child.setLayoutParams(params)
- parent calls child.getLayoutParams();
- using layoutParams the parent created measureSpecs
### (i.e. the idea: the child passes layoutParams to the parent, 
### and the parent returns measureSpecs to the child)



## child.measure()
## child.onMeasure()
### General idea:
- parent view passes constraints (i.e. measureSpec) to the child view
- the child calculates measured width and height
- the child stores the calculated sizes (i.e. calls setMeasuredDimension())
- the child recursively passes constraints to its own children (i.e. calls child.onMeasure(...))

## Method signature: void onMeasure(int widthMeasureSpec, int widthMeasureSpec)
- parent passes a 'measureSpec' (i.e. size limitations to the child) in the child.measure()
- measureSpec is an int (i.e. { mode | size })
-- AT_MOST x (i.e. be any size up to x)
-- EXACTLY x (i.e. be exactly x)
-- UNSPECIFIED (i.e. no constraints from parent to child)

### Basic implementation of onMeasure()
void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
  int myDesiredWidth = ...
  int myDesiredHeight = ...

  int measuredWidth = resolveSize(myDesiredWidth, widthMeasureSpec);
  int measuredHeight = resolveSize(myDesiredHeight, heightMeasureSpec);

  setMeasuredDimension(int measuredWidth, int measuredHeight)
}

int resolveSize(int mySize, int measureSpec) {
    int specMode = MeasureSpec.getMode(measureSpec)
    int specSize = MeasureSpec.getSize(measureSpec)

    int measuredSize;
    if (specMode == MeasureSpec.EXACTLY) {
      measuredSize = specSize;
    } else if (specMode == MeasureSpec.AT_MOST) {
      measuredSize = Math.min(mySize, specSize);
    } else {
      measuredSize = mySize;
    }
    return measuredSize;
}










### child.layout()
### child.onLayout()
### Method signature: onLayout(int left, int top, int right, int bottom)
- the parent calls child.getMeasuredWidth() and child.getMeasuredHeight()
- the parent sizes and positions its children (recursively)
- at this stage the parent can adjust the final size of the child
(i.e. child.getWidth() may differ from child.getMeasuredWidth())











### onDraw(Canvas canvas)
- the parent draws itself and asks the child to draw itself (recursively)


