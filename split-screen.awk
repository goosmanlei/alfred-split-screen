$1 == "Type:" {
    if ($0 == "Type: MacBook built in screen") {
        CurrType = "main";
    } else {
        CurrType = "dual";
    }
}
$1 == "Resolution:" {
    Resolution[CurrType] = $2;
}
$1 == "Origin:" {
    Origin[CurrType] = $2;
}
END {
    if (length(Resolution["dual"]) == 0) {
        Resolution["dual"] = Resolution["main"];
        Origin["dual"] = Origin["main"];
    }
    split(Resolution["main"], MainResolution, "x");
    split(substr(Origin["main"], 2, length(Origin["main"]) - 2), MainOrigin, ",");
    split(Resolution["dual"], DualResolution, "x");
    split(substr(Origin["dual"], 2, length(Origin["dual"]) - 2), DualOrigin, ",");
    #printf("%d\n%d\n%d\n%d\n%d\n%d\n%d\n%d", MainOrigin[1], MainOrigin[2], MainResolution[1], MainResolution[2], DualOrigin[1], DualOrigin[2], DualResolution[1], DualResolution[2]);
    printf("{\n    \"main\": {\"x\": %d, \"y\": %d, \"width\": %d, \"height\": %d},\n    \"dual\": {\"x\": %d, \"y\": %d, \"width\": %d, \"height\": %d}\n}", MainOrigin[1], MainOrigin[2], MainResolution[1], MainResolution[2], DualOrigin[1], DualOrigin[2], DualResolution[1], DualResolution[2]);
}
