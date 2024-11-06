#!/bin/bash
for oxp in tenet:Tenet:tenet.ac.za amlight:AmLight-EXP:amlight.net sax:SAX:sax.net internet2:Internet2:internet2.net esnet:ESnet:es.net geant_london:GEANT-London:london.geant.org geant_france:GEANT-France:france.geant.org lhc:LHC:lhc.cern; do
	NAME=$(echo $oxp|cut -d":" -f1)
	DESC=$(echo $oxp|cut -d":" -f2)
	DOMAIN=$(echo $oxp|cut -d":" -f3)
	sed -e "s/XXX_NAME_XXX/$NAME/g; s/XXX_DESC_XXX/$DESC/g; s/XXX_DOMAIN_XXX/$DOMAIN/g" template.env > $NAME.env
	sed -e "s/XXX_NAME_XXX/$NAME/g; s/XXX_DESC_XXX/$DESC/g; s/XXX_DOMAIN_XXX/$DOMAIN/g" template-lc.env > $NAME-lc.env
done
