<?php
# Movable Type (r) Open Source (C) 2001-2012 Six Apart, Ltd.
# This program is distributed under the terms of the
# GNU General Public License, version 2.
#
# $Id$

function smarty_function_mtgetvar($args, &$ctx) {
    require_once("function.mtvar.php");
    return smarty_function_mtvar($args, $ctx);
}
?>