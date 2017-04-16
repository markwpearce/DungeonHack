package dungeonhack.debug;

import flixel.system.debug.watch.Watch;
import flixel.system.debug.watch.EditableTextField;
import flixel.system.ui.FlxSystemButton;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import flixel.system.FlxAssets;

import flash.display.BitmapData;
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

class DebugWindow extends Watch {

  private static inline var LINE_HEIGHT:Int = 16;
  private static inline var WINDOW_WIDTH = 200;

  private static var windowCount: Int = 0;

  private var itemCount = 1;

  private var labeledButtons: Array<DebugLabledButton> = new Array<DebugLabledButton>();
   
  private var defaultFormat:TextFormat;
  
  public function new(titleText:String) {
    super(true);
    _title.text = titleText;
    windowCount++;
    resize(WINDOW_WIDTH,itemCount*LINE_HEIGHT);
    reposition(205*windowCount,0);
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
    var label = setupTextFieldForButton(new TextField(), icon != null);
    label.text = textLabel;
    button.x = 5;
    button.y=itemCount*LINE_HEIGHT;
    incItemCount();
    drawButton(button);
    button.addChild(label);
    addChild(button);
    
    var labeledButton:DebugLabledButton = new DebugLabledButton(button, label, onClick, icon);

    labeledButtons.push(labeledButton);
    return labeledButton;
  }


  

  private function drawButton(button: FlxSystemButton) {
    button.graphics.clear();
    button.graphics.beginFill(0x999999);
    button.graphics.drawRect(0, 0, this.width-10, button.height+4);
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
    resize(this.width,itemCount*LINE_HEIGHT);
  }

  private function setupTextFieldForButton(textField:TextField, hasIcon: Bool):TextField
	{
		textField.selectable = false;
		textField.defaultTextFormat = defaultFormat;
		textField.autoSize = TextFieldAutoSize.NONE;
    textField.height=LINE_HEIGHT;
    
		setTextFieldWidth(textField, hasIcon);
    return textField;
	}

  private function setTextFieldWidth(textField:TextField, hasIcon: Bool):Void {
    var iconOffset = hasIcon ? 16 : 0;
		textField.width =this.width-10-iconOffset;
    textField.x=iconOffset;
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