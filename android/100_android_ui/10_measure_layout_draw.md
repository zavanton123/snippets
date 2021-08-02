# Android onMeasure(), onLayout(), onDraw()

### How Android draws views?
### (Note: Measure, layout, draw are Depth-First-Traversals)
- Inflation/instantiation -> view hierarchy
- Measure
- Layout
- Draw

### onMeasure()
- parent view passes constraints to the child view
- the child calculates measured width and height
- the child stores the calculated sizes
- the child recursively passes constraints to its own children...


### onLayout()
- the parent sizes and positions the child 

### onDraw()
- the parent draws itself and asks the child to draw itself





### onMeasure
### Negotiating child size
### LayoutParams
- child defines LayoutParams (via Java or xml)
- child.setLayoutParams(params)
- parent calls child.getLayoutParams();

- parent passes a 'measureSpec' (i.e. size limitations to the child) in the child.measure()
- measureSpec is an int (i.e. { mode | size })
-- AT_MOST x (i.e. be any size up to x)
-- EXACTLY x (i.e. be exactly x)
-- UNSPECIFIED (i.e. no constraints from parent to child)

- child calls setMeasuredDimension()
- parent call getMeasuredDimension()


- parent calls child.layout()






## Custom LayoutParams
- checkLayoutParams()
- generateDefaultLayoutParams()
- generateLayoutParams(ViewGroup.LayoutParams params)
- generateLayoutParams(AttributeSet attrs)





