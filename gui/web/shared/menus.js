/*
   Expanding/Contracting Menus for Gold
   Author: Geoffrey Elliott
   Updated: September, 2003
*/



var menusArray = new Array("users","projects","machines","accounts","reservations","quotations","chargeRates","transactions","jobs","usages","allocations","roles","objects");

function closeMenus() {
    for(i=0; i<menusArray.length; i++) {
        if(document.getElementById(menusArray[i] + "Section")){
            document.getElementById(menusArray[i] + "Section").style.display = "none";
            document.getElementById(menusArray[i] + "Arrow").src = "images/menu_arrow_closed.gif";
        }
    }
}

function showMenu(sectionID) {
    closeMenus();
    document.getElementById(sectionID + "Section").style.display = "block";
    document.getElementById(sectionID + "Arrow").src = "images/menu_arrow_expanded.gif";
}