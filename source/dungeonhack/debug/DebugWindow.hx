

package dungeonhack.debug;

import flixel.system.debug.DebuggerUtil;
import flixel.system.debug.watch.Watch;
import flixel.system.debug.watch.EditableTextField;
import flixel.system.debug.completion.CompletionList;
import flixel.system.ui.FlxSystemButton;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import flixel.system.FlxAssets;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flixel.util.FlxDestroyUtil;
import openfl.events.KeyboardEvent;
import flixel.FlxG;

import dungeonhack.util.*;


class DebugLabledButton {
  public var icon: BitmapData;
  public var button: FlxSystemButton;
  public var label: TextField;
  public var onClick: Null<Void -> Void>;

  public function new(b: FlxSystemButton, l:TextField, onC:  Null<Void -> Void>, i: BitmapData) {
    button = b;
    label = l;
    icon = i;
    onClick = onC;
  }

  public function hasIcon():Bool {
    return icon != null;
  }

  public function destroy():Void {
    FlxDestroyUtil.removeChild(button, label);
    button.destroy();
  }
}

class DebugLabeledSelect {
  public var label: TextField;
  public var input: TextField;
  public var handler: GeneralCompletionHandler;
  public var list:CompletionList;
  public var onSelect: Null<String -> Void>;

  public var lastSelection: String = "";

  public function new(l: TextField, i: TextField, h:GeneralCompletionHandler, cl:CompletionList, onS: Null<String->Void>) {
    label = l;
    input = i;
    handler = h;
    list = cl;
    onSelect = onS;
    cl.selectionChanged = this.handleSelect;
    cl.closed = null;
  }

  public function handleSelect(selection:String):Void {
    if(selection == lastSelection || !list.visible) {
      return;
    }
    lastSelection = selection;
    input.text = selection;
    var callStack = haxe.CallStack.callStack();
    onSelect(lastSelection);
  }

  public function destroy():Void {

  }
}
#if DEBUG
class DebugWindow extends Watch {

  private static inline var LINE_HEIGHT:Int = 16;
  private static inline var WINDOW_WIDTH = 200;
  private static inline var GUTTER = 5;

  private static var windowCount: Int = 0;

  private var itemCount = 1;

  private var labeledButtons: Array<DebugLabledButton> = new Array<DebugLabledButton>();
  private var labeledSelects: Array<DebugLabeledSelect> = new Array<DebugLabeledSelect>();
 

  private var defaultFormat:TextFormat;
  
  public function new(titleText:String) {
    super(true);
    _title.text = titleText;
    windowCount++;
    windowCount = Math.floor(Math.max(1, windowCount));
    resize(WINDOW_WIDTH,itemCount*LINE_HEIGHT);
    reposition((WINDOW_WIDTH+GUTTER)*windowCount,0);
    defaultFormat = new TextFormat(FlxAssets.FONT_DEBUGGER, 12, 0xFFFFFF);
    FlxG.signals.stateSwitched.add(close);
  }

  override public function destroy():Void {
    windowCount--;
    FlxG.signals.stateSwitched.remove(close);
    for(labeledButton in labeledButtons) {
      labeledButton.destroy();
    }
    super.destroy();
  }

  public function addLabeledButton(textLabel:String,
            onClick:Null<Void -> Void>,
            ?icon:flash.display.BitmapData): DebugLabledButton {
    var button = new FlxSystemButton(icon, onClick);
    var label = setupTextField(new TextField(), icon != null);
    label.text = textLabel;
    button.x = GUTTER;
    button.y=itemCount*LINE_HEIGHT;
    incItemCount();
    drawButton(button);
    button.addChild(label);
    addChild(button);
    
    var labeledButton:DebugLabledButton = new DebugLabledButton(button, label, onClick, icon);

    labeledButtons.push(labeledButton);
    return labeledButton;
  }

  private function dummySelect(inputVal: Dynamic) {
  }


  public function addLabeledSelect(textLabel:String, selectionItems: Array<String>,onSelect:String -> Void):DebugLabeledSelect {
    var label = setupTextField(DebuggerUtil.createTextField(), false);
    setTextFieldWidth(label, false, true);
    label.x = GUTTER;
    label.y=itemCount*LINE_HEIGHT;
    label.text=textLabel;
    addChild(label);
    // Create the input textfield
		var input = new EditableTextField(true, defaultFormat, dummySelect, Type.typeof("") );
		input.embedFonts = true;
    
    
		setTextFieldWidth(label,false, true);
    input.x = label.width+GUTTER;
		input.y = itemCount*LINE_HEIGHT;
    input.autoSize = TextFieldAutoSize.NONE;
    input.height=LINE_HEIGHT;

    incItemCount();
    
    addChild(label);
    addChild(input);
    var list = new CompletionList(5);
    addChild(list);
    input.text = selectionItems[0];
    var handler = new GeneralCompletionHandler(list, input, selectionItems);
    var labeledSelect = new DebugLabeledSelect(label, input, handler, list, onSelect);
    labeledSelects.push(labeledSelect);
    return labeledSelect;
  }

  
  override public function addChild(child:DisplayObject):DisplayObject 
	{
		var result = super.addChild(child);
		// hack to make sure the completion list always stays on top
    for(labeledSelect in labeledSelects) {
      if(labeledSelect.list != null) {
        super.addChild(labeledSelect.list);
      }
    }
  
		return result;
	}

  

  private function drawButton(button: FlxSystemButton) {
    button.graphics.clear();
    button.graphics.beginFill(0x999999);
    button.graphics.drawRect(0, 0, this.width-(GUTTER*2), button.height+4);
    button.graphics.endFill();
  }

  public function addWatch(thisObj:Dynamic, name:String, prop:String):Void {
    add(prop, FIELD(thisObj, prop));
    var removeButton = entries[entries.length-1].getChildAt(2);
    removeButton.visible=false;
    var editField = cast(entries[entries.length-1].getChildAt(1), EditableTextField);
    Reflect.setField(editField, "allowEditing", false);
    editField.needsSoftKeyboard = false;
    
    incItemCount();
  }

  private function incItemCount() {
    itemCount++;
    resize(this.width,(itemCount+1)*LINE_HEIGHT);
  }

  private function setupTextField(textField:TextField, hasIcon: Bool, halfSize:Bool = false):TextField
	{
		textField.selectable = false;
		textField.defaultTextFormat = defaultFormat;
		textField.autoSize = TextFieldAutoSize.NONE;
    textField.height=LINE_HEIGHT;
    
		setTextFieldWidth(textField, hasIcon, halfSize);
    return textField;
	}

  private function setTextFieldWidth(textField:TextField, hasIcon: Bool, halfSize:Bool = false):Void {
    var iconOffset = hasIcon ? 16 : 0;
		textField.width =this.width-10-iconOffset;
    textField.x=iconOffset;
    if(halfSize) {
      textField.width /=2;
    }
  }

  override public function update(): Void {
    super.update();
  }


  override public function updateSize():Void {
    super.updateSize();
    for(labeledButton in labeledButtons){
      setTextFieldWidth(labeledButton.label, labeledButton.icon != null);
      drawButton(labeledButton.button);
    }
  }
}
#end
#if !DEBUG
class DebugWindow {

  public function new(titleText:String) {  }

  public function addLabeledButton(textLabel:String,
            onClick:Null<Void -> Void>,
            ?icon:flash.display.BitmapData): DebugLabledButton {
    return null;
  }

  public function addLabeledSelect(textLabel:String, selectionItems: Array<String>,onSelect:String -> Void):DebugLabeledSelect {
    return null;
  }

  public function addWatch(thisObj:Dynamic, name:String, prop:String):Void {  }

  public function resize(x:Int, y:Int):Void { }
  public function close():Void { }
  public function update():Void { }
}
#end