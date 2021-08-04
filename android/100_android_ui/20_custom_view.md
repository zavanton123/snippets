# Custom View

### View life cycle 
CustomView constructor -> onAttachedToWindow() -> 
    (return here after requestLayout() call)
-> measure() -> onMeasure() -> 
-> layout() -> onLayout() -> 
    (return here after invalidate() call)
-> dispatchDraw() -> draw() -> onDraw()



## View Constructor
### when created from code:
- CustomView (Context context)
### when created from xml:
- CustomView (Context context, AttributeSet attrs)
- CustomView (Context context, AttributeSet attrs, int defStyleAttr)
- CustomView (Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes)



## child.onAttachedToWindow()
### onAttachedToWindow() is called after parent.addView(child) is called
### The child becomes a part in the parent's view hierarchy
### child.setLayoutParams(params) and child.getLayoutParams() are called
### (i.e. the idea: the child passes layoutParams to the parent, 
### and the parent returns measureSpecs to the child)



## child.measure()
## child.onMeasure()
### measureSpec is a binary, it consists of 'mode' (EXACTLY, AT_MOST, UNSPECIFIED) and 'size'

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






## child.layout() 
## child.onLayout() (calls child.getMeasuredWidth() and child.getMeasuredHeight())



## child.onDraw(Canvas canvas)

