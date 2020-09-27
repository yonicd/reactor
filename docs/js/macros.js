remark.macros.scale = function(w) {
  var url = this;
  return '<img src="' + url + '" style="width: ' + w + ';" />';
};

remark.macros.scale_right = function(w) {
  var url = this;
  return '<img src="' + url + '" style="width: ' + w + ';float:right;margin-left:20px" />';
};

remark.macros.scale_center = function(w) {
  var url = this;
  return '<img src="' + url + '" style="width: ' + w + ';margin-left:200px" />';
};
