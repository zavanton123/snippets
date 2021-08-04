# Custom View

### Custom View life cycle 
CustomView constructor -> onAttachedToWindow() -> 
(after requestLayout() call)
-> measure() -> onMeasure() -> 
-> layout() -> onLayout() -> 
(after invalidate() call)
-> dispatchDraw() -> draw() -> onDraw()



## Custom view constructor
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
protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec)
int spec = mode | size

### Types of mode:
- MeasureSpec.EXACTLY
- MeasureSpec.AT_MOST
- MeasureSpec.UNSPECIFIED

### resolveSize(int myWidth, int widthMeasureSpec)
int specMode = MeasureSpec.getMode(widthMeasureSpec)
int specSize = MeasureSpec.getSize(widthMeasureSpec)

int measuredWidth;
if (specMode == MeasureSpec.EXACTLY) {
  measuredWidth = specSize;
} else if (specMode == MeasureSpec.AT_MOST) {
  measuredWidth = Math.min(myWidth, specSize);
} else {
  measuredWidth = myWidth;
}

setMeasuredDimension(int measuredWidth, int measuredHeight)



## child.getMeasuredWidth() and child.getMeasuredHeight()



## child.layout()
### child.getWidth() and child.getHeight()



## child.onLayout()



## child.onDraw(Canvas canvas)













